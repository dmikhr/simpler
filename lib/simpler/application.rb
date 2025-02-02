require 'yaml'
require 'singleton'
require 'sequel'
require_relative 'router'
require_relative 'controller'

module Simpler
  class Application

    include Singleton

    attr_reader :db

    def initialize
      @router = Router.new
      @db = nil
    end

    def bootstrap!
      setup_database
      require_app
      require_routes
    end

    def routes(&block)
      @router.instance_eval(&block)
    end

    def call(env)
      # puts "ENV #{env['REQUEST_METHOD']} #{env['PATH_INFO']}"
      route = @router.route_for(env)
      #puts "ROUTE #{route.nil?}"
      if route.nil?
        # если route не найден, возвращаем Rack ответ [status, headers, body]
        [404, { 'Content-Type' => 'text/plain' }, ["Error 404: Path #{env['PATH_INFO']} not found"]]
      else
        # параметры в момент обращения к .params доступные в env
        env['simpler.params'] = route.params(env)
        controller = route.controller.new(env)
        action = route.action
        make_response(controller, action)
      end
    end

    private

    def require_app
      Dir["#{Simpler.root}/app/**/*.rb"].each { |file| require file }
    end

    def require_routes
      require Simpler.root.join('config/routes')
    end

    def setup_database
      database_config = YAML.load_file(Simpler.root.join('config/database.yml'))
      database_config['database'] = Simpler.root.join(database_config['database'])
      @db = Sequel.connect(database_config)
    end

    def make_response(controller, action)
      controller.make_response(action)
    end

  end
end
