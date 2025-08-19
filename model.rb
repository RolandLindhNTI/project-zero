    def database(db2)
        db = SQLite3::Database.new(db2)
        db.results_as_hash = true
        return db
    end