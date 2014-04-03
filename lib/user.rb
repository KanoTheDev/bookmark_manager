require 'bcrypt'
class User


	
	include DataMapper::Resource
	attr_reader :password
	attr_accessor :password_confirmation
	validates_confirmation_of :password, :message => "Sorry, your passwords don't match"


	property :id, Serial
	property :email, String, :unique => true, :message => "This email is already taken"
	property :password_digest, Text
	property :password_token, Text
	property :pass_token_exp_date, DateTime


	def password=(password)
		@password = password
		self.password_digest = BCrypt::Password.create(password)
	end

	def self.authenticate(email, password)
		user = first(:email => email)
		if user && BCrypt::Password.new(user.password_digest) == password
			user
		else
			nil
		end
	end

	def send_token
		RestClient.post "https://api:key-8yeqz3amluwtgbiyuepc4a1tixryzqg6"\
	  "@api.mailgun.net/v2/sandbox10147.mailgun.org/messages",
	  :from => "Nobody knows <postmaster@sandbox10147.mailgun.org>",
	  :to => "<#{self.email}>",
	  :subject => "Reset password instruction",
	  :text => "Someone has requested a link to change your password,
	   and you can do this by using this link bellow
	   http://localhost:4567/users/reset_password/#{self.password_token}"
	end

	def delete_token
		self.password_token = ''
	end

end