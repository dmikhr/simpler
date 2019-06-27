class TestsController < Simpler::Controller

  def index
    @time = Time.now
    # status 302
    # headers 'text/text'
    # headers 'text/html'
    # передаем в метод render хеш с ключом и текстовым значением
    # render plain: 'Test text plain'
    # render html: '<b>Hello!</b>'
    # render 'tests/list'
    # render zip: 'str' # несуществующий ключ - приведет к http error 500
  end

  def create

  end

  def show
    @params = params
  end

  def manage
    @params = params
    render json: ''
  end

end
