require 'spec_helper'
require_relative 'helpers/session'

include SessionHelpers

feature "Sser signs up" do
	scenario "when being logged out" do
		lambda { sign_up }.should change(User, :count).by(1)
		expect(page).to have_content("Welcome, alice@example.com")
		expect(User.first.email).to eq("alice@example.com")
	end

	scenario "with a password that doesn't match" do
		lambda { sign_up('a@a.com', 'pass', 'wrong') }.should change(User, :count).by(0)
		expect(current_path).to eq('/users')
		expect(page).to have_content("Sorry, your passwords don't match")
	end

	scenario "with an email that is already registered" do
		lambda { sign_up }.should change(User, :count).by(1)
		lambda { sign_up }.should change(User, :count).by(0)
		expect(page).to have_content("This email is already taken")
	end
end

feature "User signs in" do

	before(:each) do
		User.create(:email => 'test@test.com',
								:password => 'test',
								:password_confirmation => 'test')
	end

	scenario "with correct credentials" do
    visit '/'
    expect(page).not_to have_content("Welcome, test@test.com")
    sign_in('test@test.com', 'test')
    expect(page).to have_content("Welcome, test@test.com")
  end

	scenario "with incorrect credentials" do
		visit '/'
		expect(page).not_to have_content("Welcome, test@test.com")
		sign_in('test@test.com', 'wrong')
		expect(page).not_to have_content("Welcome, test@test.com")
	end

end

feature "User signs out" do
	before(:each) do
		User.create(:email => "test@test.com", 
								:password => 'test',
								:password_confirmation => 'test')
	end

		scenario 'while being signed in' do
			sign_in('test@test.com', 'test')
			click_button "Sign out"
			expect(page).to have_content("Good bye!")
			expect(page).not_to have_content("Welcome, test@test.com")
		end
end

feature "User forgets password and fills password reset form" do

	before(:each) do
		user = User.create(:email => 'test@test.com', 
								:password => 'test',
								:password_confirmation => 'test')
	end

	scenario 'with correct email' do
		visit '/users/reset_password'
    fill_in :email, :with => 'test@test.com'
    click_button "Reset"
    expect(page).to have_content("Password reset link sent to your email")
    expect(User.first.password_token).not_to eq nil    
    expect(User.first.pass_token_exp_date).not_to eq nil
	end

	scenario 'with incorrect email' do
		visit '/users/reset_password'
    fill_in :email, :with => 'spam@test.com'
    click_button "Reset"
    expect(page).not_to have_content("Password reset link sent to your email")
    expect(page).to have_content("Try again with correct email.")
    expect(User.first.password_token).to eq nil
    expect(User.first.pass_token_exp_date).to eq nil
	end

end


feature "User gets the link to reset password" do
	before(:each) do
		User.create(:email => 'test@test.com', 
								:password => 'forgotten_password',
								:password_confirmation => 'forgotten_password',
								:password_token => 'RESET_TOKEN')
	end

	scenario 'presses the link and fills two fields correcty' do

		visit "/users/reset_password/RESET_TOKEN"
		expect(page).to have_content("Please set new password for your account")
		fill_in 'email', :with => 'test@test.com'
		fill_in 'password', :with => 'new_password'
		fill_in 'password_confirmation', :with => 'new_password'
		click_button 'Set password'
		# expect(page).to have_content("Password saved successfuly!")
		sign_in('test@test.com','new_password')
		expect(page).to have_content("Welcome, test@test.com")
	end

	scenario 'presses the link and fills two fields incorrecty' do

		user = User.find(:password_token => 'ASDF')
		visit "/users/reset_password/RESET_TOKEN"
		expect(page).to have_content("Please set new password for your account")
		fill_in 'email', :with => 'test@test.com'
		fill_in 'password', :with => 'qwerty'
		fill_in 'password_confirmation', :with => 'qwert'
		click_button 'Set password'
		expect(page).to have_content("Try again with same passwords.")
	end



end