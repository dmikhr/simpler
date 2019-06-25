module Simpler
  class Router
    class Route

      attr_reader :controller, :action, :params

      def initialize(method, path, controller, action)
        @method = method
        @path = path
        @controller = controller
        @action = action
        @params = {}
      end

      def match?(method, path)
        @method == method && path_match(path)
      end

      private

      def path_match(path)
        request_path_elements = split_path(path)
        route_path_elements = split_path(@path)
        # если запрос полностью совпадает с роутом (например: /tests - /tests) - то возвращаем true
        return true if request_full_match_route?(request_path_elements, route_path_elements)
        # если запрос сложный (/tests/1), проверяем на совпадение шаблону запроса (/tests/:id - /tests/1)
        return false unless request_match_route?(request_path_elements, route_path_elements)
        # если шаблон подходит, проверяем наличие в нем параметра и извлекаем его при наличии
        manage_params(request_path_elements, route_path_elements)
      end

      # 'path=/tests/, @path=/tests', 'path=/tests/101, @path=/tests'
      def split_path(path)
        path = path.split('/')
        # убираем пустые элементы ["", "tests", "1"] -> ["tests", "1"]
        path.delete("")
        path
      end

      def manage_params(request, route)
        potential_param = route.last
        if potential_param[0] == ':'
          # :id -> id
          param = potential_param[1, potential_param.size]
          @params[param.to_sym] = request.last
        end
      end

      def request_match_route?(request, route)
        request.first == route.first && request.count == route.count
      end

      def request_full_match_route?(request, route)
        request_match_route?(request, route) && request.count == 1
      end
    end
  end
end
