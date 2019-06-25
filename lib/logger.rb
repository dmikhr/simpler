# подключение logger middleware к фреймворку по аналогии с https://redpanthers.co/rack-middleware/
class Logger

  LOG_FILE = "#{Simpler.root}/log/app.log"

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    log_data = report(env, status, headers)
    File.write(LOG_FILE, log_data, mode: 'a')
    [status, headers, body]
  end

  private

  def report(env, status, headers)
    template = ->(action) { action ? "#{path_to_folder_name(env['REQUEST_PATH'])}/#{action}.html.erb" : "none" }
    handler = ->(controller) { controller ? "#{controller.class}##{env['simpler.action']}" : "none" }
    parameters = ->(params) { params && params.any? ? params : "none" }
    info = [Time.now.strftime('%d-%m-%Y %H:%M:%S'),
            "Request: #{env['REQUEST_METHOD']} #{env['REQUEST_PATH']}",
            "Handler: #{handler.call(env['simpler.controller'])}",
            "Parameters: #{parameters.call(env['simpler.params'])}",
            "Response: #{status} [#{headers['Content-Type']}] #{template.call(env['simpler.action'])}"]
    "#{info.join("\t")}\n"
  end

  # название папки контроллера
  def path_to_folder_name(path)
    elements = path.split('/')
    elements.delete('')
    elements.first
  end

end
