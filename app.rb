require "slim"
require "sinatra"
require "sqlite3"
require "sinatra/reloader"
require 'sinatra/flash' 
require_relative 'model.rb'


before do
    @db = database("db/projectzerodatabase.db")
end

error 404 do
    flash[:notice] = "Route does not exist"
    redirect('/')
end

get('/') do
    @result = @db.execute("SELECT * FROM TE4")
    slim(:index)
end

