class HtmlRender < Render

  def render
    ERB.new(@template).result(@binding)
  end
end
