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
      if @response.body.empty?
        body = render_body
        @response.write(body)
      end
    end

    def render_body
      View.new(@request.env).render(binding)
    end

    def params
      # @request.params - хеш, добавляем в него параметр id
      @request.params.merge(@request.env['simpler.params'])
    end

    def render(template)
      # есть ли в template ключ :plain
      if template.key?(:plain)
        render_plain(template[:plain])
      else
        @request.env['simpler.template'] = template
      end
    end

    def render_plain(template)
      headers 'text/plain'
      @response.write(template)
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
