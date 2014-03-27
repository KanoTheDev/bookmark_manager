require 'data_mapper'
require 'sinatra'
require './lib/link'
require './lib/tag'
require './lib/user'
require 'rack-flash'
require 'rest_client'

require_relative 'views/helpers/application'

use Rack::Flash  

env = ENV["RACK_ENV"] || "development"
DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")
DataMapper.finalize
DataMapper.auto_upgrade!

enable :sessions
set :session_secret, 'superpass sdfsdfsdf'


class BookmarkManager < Sinatra::Application

	get '/' do
		@links = Link.all
		erb :index
	end

	post '/links' do
		url = params["url"]
		title = params["title"]
		tags = params["tags"].split(" ").map do |tag|
			Tag.first_or_create(:text => tag)
		end
		Link.create(:url => url, :title => title, :tags => tags)
		redirect to('/')
	end

	get '/tags/:text' do
		tag = Tag.first(:text => params[:text])
		@links = tag ? tag.links : []
		erb :index
	end

 	get '/users/new' do
 		@user = User.new
 		erb :"users/new"
 	end

 	post '/users' do
 		@user = User.create(:email 		=> params[:email],
 								:password => params[:password],
 								:password_confirmation => params[:password_confirmation])
 		if @user.save
 			session[:user_id] = @user.id
 			redirect to('/')
 		else
 			flash.now[:errors] = @user.errors.full_messages
 			erb :"users/new"
 		end
 	end

 	get '/sessions/new' do
 		erb :"sessions/new"
 	end

	post '/sessions' do
	  email, password = params[:email], params[:password]
	  user = User.authenticate(email, password)
	  if user
	    session[:user_id] = user.id
	    redirect to('/')
	  else
	    flash[:errors] = ["The email or password are incorrect"]
	    erb :"sessions/new"
	  end
	end

	delete '/sessions' do
		session[:user_id] = nil
		flash[:notice] = "Good bye!"
    redirect to('/')
  end

  get '/users/reset_password' do
  	erb :"users/reset_password"
  end

 	post '/users/reset_password' do
 		user = User.first(:email => params[:email])
 		if user
 			user.password_token = (1..64).map{('A'..'Z').to_a.sample}.join
 			user.password_token_timestamp = Time.now
 			user.save
  		flash[:notice] = "Password reset link sent to your email"
  		erb :"users/reset_password"
  	else
  		flash[:errors] = ["Try again with correct email."]
  		erb :"users/reset_password"
  	end

  end
end