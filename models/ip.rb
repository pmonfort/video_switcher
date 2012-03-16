require 'rubygems'
require 'sequel'

USER = 'root'
PASSWORD = 'root'

DB = Sequel.connect(:adapter => 'mysql2', :user => USER, :host => 'localhost', :database => 'qr',:password => PASSWORD)

# create an items table
DB.create_table? :ips do
  primary_key :id
  String :ip_from
  String :ip_to
  String :country
  String :video
end

class Ip < Sequel::Model;
end
