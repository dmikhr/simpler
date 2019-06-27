require 'json'
class JsonRender < Render
  def render
    JSON.generate(@template)
  end
end
