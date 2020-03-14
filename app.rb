# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

places_table = DB.from(:places)
comments_table = DB.from(:comments)
users_table = DB.from(:users)

before do
    @current_user = users_table.where(id: session["user_id"]).to_a[0]
end

# Homepage
get "/" do
    puts places_table.all
    @places = places_table.all.to_a
    view "places"
end

# Place details
get "/places/:id" do
    @place = places_table.where(id: params[:id]).to_a[0]
    @comments = comments_table.where(place_id: @place[:id])
    @users_table = users_table
    view "place"
end

# geocode
    # results = Geocoder.search(@place[:location])
    # @georesults = results.first.coordinates # => [lat, long]
    # @lat = @georesults[0]
    # @long = @georesults[1]
    # @lat_long = "#{@lat},#{@long}"
    # view "place"

# comment form 
    get "/places/:id/comments/new" do
    @place = places_table.where(id: params[:id]).to_a[0]
    view "new_comment"
end


# submitted info
get "/places/:id/comments/create" do
    puts params
    @place = places_table.where(id: params["id"]).to_a[0]
    comments_table.insert(place_id: params["id"],
                       user_id: session["user_id"],
                       comments: params["comments"])
    view "create_comment"
end

get "/users/new" do
    view "new_user"
end

#login info belowis
post "/users/create" do
    puts params
    hashed_password = BCrypt::Password.create(params["password"])
    users_table.insert(name: params["name"], email: params["email"], password: hashed_password)
    view "create_user"
end

get "/logins/new" do
    view "new_login"
end

post "/logins/create" do
    user = users_table.where(email: params["email"]).to_a[0]
    puts BCrypt::Password::new(user[:password])
    if user && BCrypt::Password::new(user[:password]) == params["password"]
        session["user_id"] = user[:id]
        @current_user = user
        view "create_login"
    else
        view "create_login_failed"
    end
end

get "/logout" do
    session["user_id"] = nil
    @current_user = nil
    view "logout"
end