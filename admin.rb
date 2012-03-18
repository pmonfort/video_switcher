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
  @ips = Ip.all
  haml :'admin/ips/index'
end

get '/admin/ips/add' do
  protected!
  @ip = Ip.new
  @actionUrl = "/admin/ips/add"
  haml :'admin/ips/add'
end

post '/admin/ips/add' do
  protected!
  @ip = Ip.new
  @ip.ip_from = params[:ip_from]
  @ip.ip_to = params[:ip_to]
  @ip.country = params[:country]
  @ip.video = params[:video][:tempfile].path
  @ip.save
  redirect '/admin'
end

get '/admin/ips/:id' do
  protected!
  @ip = Ip[:id => params[:id]]
  if @ip.nil?
    haml :'404'
  end
  @actionUrl = "/admin/ips/" + @ip[:id].to_s
  haml :'admin/ips/ip'
end

post '/admin/ips/:id' do
  protected!
  ip_from = params[:ip_from]
  ip_to = params[:ip_to]
  country = params[:country]
  video = params[:video]
  @ip = Ip[:id => params[:id]]
  @ip.update(:ip_from => ip_from, :ip_to => ip_to, :country => country, :video => video)
  redirect '/admin'
end
