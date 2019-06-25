class TestsController < Simpler::Controller

  def index
    @time = Time.now
    # status 302
    # headers 'text/text'
    # headers 'text/html'
    # передаем с метод render хеш с ключом :plain и текстовым значением
    # render plain: 'Test text'
  end

  def create

  end

  def show
    @params = params
  end

end
