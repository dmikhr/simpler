module Simpler
  class Router
    class Route

      attr_reader :controller, :action

      def initialize(method, path, controller, action)
        @method = method
        @path = path
        @controller = controller
        @action = action
      end

      def match?(method, path)
        @method == method && path_match(path)
      end

      # возвращаем параметры без сохранения в инстанс-переменную
      def params(env)
        path = env['PATH_INFO']
        path_match(path)
      end

      private

      def path_match(path)
        request_path_elements = split_path(path)
        route_path_elements = split_path(@path)
        extract_params(request_path_elements, route_path_elements) if request_match_route?(request_path_elements, route_path_elements)
      end

      def split_path(path)
        path = path.split('/')
        # убираем пустые элементы ["", "tests", "1"] -> ["tests", "1"]
        path.delete("")
        path
      end

      def extract_params(request, route)
        # выделяем из роута параметры и конвертируем в символы
        params = route.select { |param| param[0] == ':' }.map{ |param| param.delete_prefix(':') }.map(&:to_sym)
        # индексы элементов роута, в которых находятся параметры (для извлечения значений параметров из запроса)
        params_idx = route.each_index.select { |i| route[i][0] == ':' }
        # собираем массивы параметров и их значений в хеш
        Hash[params.zip(request.values_at(*params_idx))]
      end

      def request_match_route?(request, route)
        if request.count == route.count
          # индексы элементов роута, не являющиеся параметрами
          route_path_parts_idx = route.each_index.select { |i| route[i][0] != ':' }
          # проверяем, что они находятся на тех же местах в пути запроса, что и в шаблоне
          # например: tests/:id/data/:day/show - tests/1/data/10/show
          # элементы tests, data и show в обоих случаях должны быть в позициях 0, 2, 4
          request.values_at(*route_path_parts_idx) == route.values_at(*route_path_parts_idx)
        end
      end
    end
  end
end
