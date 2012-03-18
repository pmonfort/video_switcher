USER = "admin"
PASSWORD = "admin"

helpers do
  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [USER, PASSWORD]
  end
end

get '/admin' do
  protected!
  @countries = Country.all
  haml :'admin/countries/index'
end

get '/admin/countries/add' do
  protected!
  @country = Country.new
  @actionUrl = "/admin/countries/add"
  haml :'admin/countries/add'
end

post '/admin/countries/add' do
  protected!
  @country = Country.new
  @country.ip_from = params[:ip_from]
  @country.ip_to = params[:ip_to]
  @country.country = params[:country]
  @country.video = params[:video][:tempfile].path
  @country.save
  redirect '/admin'
end

get '/admin/countries/:id' do
  protected!
  @country = Country[:id => params[:id]]
  if @country.nil?
    haml :'404'
  end
  @actionUrl = "/admin/countries/" + @country[:id].to_s
  haml :'admin/countries/country'
end

post '/admin/countries/:id' do
  protected!
  @country = Country[:id => params[:id]]
  @country.ip_from = params[:ip_from]
  @country.ip_to = params[:ip_to]
  @country.country = params[:country]
  @country.video_original = params[:video][:tempfile].path unless params[:video].nil?
  @country.save
  redirect '/admin'
end

get '/admin/countries/:id/delete' do
  protected!
  @country = Country[:id => params[:id]]
  @country.destroy
  redirect '/admin'
end