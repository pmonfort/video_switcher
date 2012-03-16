require 'rubygems'
require 'sequel'

DB = Sequel.connect(:adapter => 'mysql2', :user => 'root', :host => 'localhost', :database => 'qr',:password=>'3578')

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
