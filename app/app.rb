require 'data_mapper'
require 'sinatra'
require 'sinatra/partial'
require 'rack-flash'
require 'rest_client'

require_relative 'controllers/users'
require_relative 'controllers/sessions'
require_relative 'controllers/links'
require_relative 'controllers/tags'
require_relative 'controllers/application'

require_relative 'helpers/application'

require_relative 'models/link'
require_relative 'models/tag'
require_relative 'models/user'

require_relative 'data_mapper_setup'

use Rack::Flash  

enable :sessions
set :session_secret, 'superpass sdfsdfsdf'
set :partial_template_engine, :erb