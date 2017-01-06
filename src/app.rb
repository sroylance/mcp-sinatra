require 'sinatra/base'
require 'cimpress_mcp'

class McpSinatraApp < Sinatra::Base
    set :root, File.dirname(__FILE__)
    use Rack::Session::Pool

    get '/' do
        erb :index
    end

    get '/login' do
        erb :login
    end

    post '/login' do
        session[:user_id] = Cimpress_mcp::Client.new(username: params[:email], password: params[:password])
        redirect('/')
    end

    get '/logout' do
        session[:user_id].clear
        redirect('/')
    end

    get '/products' do
        if !is_logged_in? then
            "Nope"
        else
            erb :products, :locals => { :products => session[:user_id].list_products }
        end
    end

    private

    def is_logged_in?
        return !!session[:user_id]
    end
end