require 'sinatra/base'
require 'rack-flash'

class UsersController < ApplicationController

  enable :sessions
  use Rack::Flash

  get '/signup' do

    if Helpers.is_logged_in?(session)
      redirect to '/tweets'
    end

    erb :'users/new_user'

  end

  post '/signup' do

    if params[:username].empty? || params[:email].empty? || params[:password].empty?
        flash[:user_error] = "Form must be fully completed."
        #erb :"users/new_user"
        #flash will work under erb - spec tests are looking for a redirect.
        redirect to '/signup'
    else
      user = User.create(:username => params["username"], :email => params["email"], :password => params["password"])
      session[:user_id] = user.id
      redirect to '/tweets'
    end

  end

  get '/login' do

    if Helpers.is_logged_in?(session)
      redirect to '/tweets'
    end

    erb :'/users/login'

  end

  post '/login' do

    user = User.find_by(:username => params["username"])

    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect to '/tweets'
    else
      flash[:login_error] = "Incorrect login. Please try again."
      redirect to '/login'
    end

  end

  get '/users/:slug' do

    slug = params[:slug]
    @user = User.find_by_slug(slug)
    erb :"users/show"

  end

  get '/logout' do

    if Helpers.is_logged_in?(session)
      session.clear
      redirect to '/login'
    else
      redirect to '/'
    end

  end

end
