require_relative 'view'

module Simpler
  class Controller

    attr_reader :name, :request, :response

    def initialize(env)
      @name = extract_name
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
    end

    def make_response(action)
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action

      set_default_headers
      send(action)
      write_response

      @response.finish
    end

    private

    def extract_name
      self.class.name.match('(?<name>.+)Controller')[:name].downcase
    end

    def set_default_headers
      @response['Content-Type'] = 'text/html'
    end

    def write_response
      # рендерим view только если в body ничего нет
      # проверка на случай если был вызван render_plain и уже заполнил @response.body
      # https://www.rubydoc.info/gems/rack/Rack/Response#body-instance_method
      body = render_body
      @response.write(body)
    end

    def render_body
      View.new(@request.env).render(binding)
    end

    def params
      # @request.params - хеш, добавляем в него параметр id
      @request.params.merge(@request.env['simpler.params'])
    end

    def render(template)
      # если передан хеш, предполагаем, что хеш содержит 1 ключ в формате render_type: 'content'
      method_name = "render_#{template.keys.first.to_s}".to_sym if template.class == Hash
      # динамически вызываем метод, который задается ключом, добавляя префикс render_
      # respond_to? с доп. параметром true, т.к. проверяем существование приватного метода
      if method_name && respond_to?(method_name, true)
        send(method_name, template[template.keys.first])
      elsif template.class == String
        # если задана строка, рендерим из файла
        render_file(template)
      else
        # если ключ не найден - ошибка
        render_error
      end
    end

    # в контроллере render_* отвечает за установку заголовков, назначение шаблона и вида рендеринга
    # сам рендеринг производится в классе, инстанцируемом во views, данные передаются через переменные окружения
    def render_plain(template)
      headers 'text/plain'
      @request.env['simpler.render_class'] = 'plain'
      @request.env['simpler.template'] = template
    end

    def render_html(template)
      headers 'text/html'
      @request.env['simpler.render_class'] = 'html'
      @request.env['simpler.template'] = template
    end

    def render_json(template)
      headers 'application/json'
      @request.env['simpler.render_class'] = 'json'
      # выведем параметры запроса в формате json
      @request.env['simpler.template'] = params
    end

    def render_file(template)
      headers 'text/html'
      @request.env['simpler.render_class'] = 'file'
      @request.env['simpler.template'] = template
    end

    def render_error
      status 500
    end

    # https://www.rubydoc.info/gems/rack/Rack/Response#status-instance_method
    def status(value)
      @response.status = value
    end

    def headers(header_type)
      @response['Content-Type'] = header_type
    end

  end
end
