require 'sinatra/base'
require 'cimpress_mcp'
require_relative 'helpers/mcp_document_generator'

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

    get '/products/:sku/designer' do
        if !is_logged_in? then
            "Nope"
        else
            product = session[:user_id].get_product(sku: params['sku'])
            erb :designer, :locals => { :product => product }
		end
	end

    post '/products/:sku/details' do
        generator = McpDocument::Generator.new()
        surfaces = session[:user_id].get_surfaces(sku: params[:sku])['Surfaces']
        temp_document = generator.create_document(width: surfaces[0]['WidthInMm'], height: surfaces[0]['HeightInMm'], document_text: params['document_text'])
        uploaded_document = session[:user_id].upload_file(file: File.new(temp_document))
        document = session[:user_id].create_document(sku: params[:sku], upload: "https://uploads.documents.cimpress.io/v1/uploads/#{uploaded_document['uploadId']}")
        scene = session[:user_id].get_scene_render(document_reference: URI.escape(document['Output']['PreviewInstructionSourceUrl'], /\W/), width: 512)
        erb :details, :locals => {
                                    :document_preview => scene['Scenes'][0]['RenderingUrl'],
                                    :sku => params[:sku]
                                 }
    end

	post '/recommendation' do
		recommendation = session[:user_id].get_fulfillment_recommendations(sku: params[:sku], quantity: params[:quantity], country: params[:country], postal_code: params[:postal_code]);
		erb :recommendation, :locals => { :recommendations => recommendation['recommendations'] }
	end

    private

    def is_logged_in?
        return !!session[:user_id]
    end
end