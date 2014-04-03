class BookmarkManager < Sinatra::Application
	
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

 	  get '/users/reset_password' do
  	erb :"users/reset_password"
  end

 	post '/users/reset_password' do
 		user = User.first(:email => params[:email])
 		if user
 			user.password_token = (1..64).map{('A'..'Z').to_a.sample}.join
 			user.pass_token_exp_date = Time.now
 			user.save
 			user.send_token
 			user.delete_token
  		flash[:notice] = "Password reset link sent to your email"
  		erb :"users/reset_password"
  	else
  		flash[:errors] = ["Try again with correct email."]
  		erb :"users/reset_password"
  	end
  end

  get "/users/reset_password/:token" do
  	erb :"users/set_new_password"
	end

	post "/users/set_new_password" do
		user = User.first(:email => params[:email], :password_token => params[:token])
		if params[:password] == params[:password_confirmation] && params[:password]
			user.update(:password => params[:password],
 									:password_confirmation => params[:password_confirmation])
			flash[:notice] = "Password saved successfully"
			redirect to('/sessions/new')
		else
			flash[:errors] = ["Try again with same passwords."]
			erb :"users/set_new_password"
		end
	end

end