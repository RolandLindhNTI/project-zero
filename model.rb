    def database()
        db = SQLite3::Database.new("db/project_zero.db")
        db.results_as_hash = true
        return db
    end