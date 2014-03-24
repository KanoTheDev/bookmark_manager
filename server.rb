require 'data_mapper'
require 'sinatra'

env = ENV["RACK_ENV"] || "development"
DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")

require './lib/link'

DataMapper.finalize
DataMapper.auto_upgrade!

class BookmarkManager < Sinatra::Application

	get '/' do
	 @links = Link.all
	 erb :index
	end

end