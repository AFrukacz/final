# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :places do
  primary_key :id
  String :title
  String :description, text: true
  String :date
  String :location
end
DB.create_table! :comments do
  primary_key :id
  foreign_key :places_id
  foreign_key :user_id
  Boolean :going
  String :comments, text: true
end
DB.create_table! :users do
  primary_key :id
  String :name
  String :email
  String :password
end

# Insert initial (seed) data
places_table = DB.from(:places)

places_table.insert(title: "The BK Lounge", 
                    description: "The ONLY place for late night eats.",
                    location: "1740 Orrington Rd")

places_table.insert(title: "Bat 17", 
                    description: "Sandwiches, beers, and BIGGER sandwiches",
                    location: "1709 Benson Ave")

places_table.insert(title: "Buffalo Joe's", 
                    description: "North Side's best wings! Period.",
                    location: "812 Clark St")                    
