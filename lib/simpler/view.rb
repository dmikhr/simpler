require 'erb'
require 'active_support/all'
require_relative 'renders/render'
require_relative 'renders/plain_render'
require_relative 'renders/html_render'
require_relative 'renders/json_render'

module Simpler
  class View

    VIEW_BASE_PATH = 'app/views'.freeze

    def initialize(env)
      @env = env
    end

    def render(binding)
      if render_class && render_class != 'file'
        # динамически создаем инстанс нужного класса (например PlainRender)
        # через метод constantize из ActiveSupport и делегируем метод render
        "#{render_class.capitalize}Render".constantize.new(template, binding).render
      else
        # вариант по умолчанию, если render не задан в контроллере или задан путь к файлу
        render_file(binding)
      end
    end

    private

    def render_file(binding)
      template = File.read(template_path)

      ERB.new(template).result(binding)
    end

    def render_class
      @env['simpler.render_class']
    end

    def controller
      @env['simpler.controller']
    end

    def action
      @env['simpler.action']
    end

    def template
      @env['simpler.template']
    end

    def template_path
      path = template || [controller.name, action].join('/')
      Simpler.root.join(VIEW_BASE_PATH, "#{path}.html.erb")
    end

  end
end
