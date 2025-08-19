module Model  

require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'

    
    
    
    def database()
        db = SQLite3::Database.new(db/"projectzerodatabase.db")
        db.results_as_hash = true
        return db
    end

end