class BookmarkManager < Sinatra::Application

	get '/' do
	  @links = Link.all
	  erb :index
	end
	
end