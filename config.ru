require_relative 'config/environment'
require_relative 'lib/logger'

use Logger
run Simpler.application
