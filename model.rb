module Model  
    require 'sinatra'
    require 'sinatra/reloader'
    require 'slim'
    require 'sqlite3'
    require 'bcrypt'

    
    
    
    def database()
        db = SQLite3::Database.new('db/projectzerodatabase.db')
        db.results_as_hash = true
        return db
    end

    def post_answer(id)
        redirect('/game')
    end

    def database_copy()
        db_copy = SQLite3::Database.new('db/projectzerodatabasecopy.db')
        db.results_as_hash = true
        return db_copy
    end

end