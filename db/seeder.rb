require 'sqlite3'

class Seeder
  
  def self.seed!
    drop_tables
    create_tables
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS todoList')
  end

  def self.create_tables
    db.execute('CREATE TABLE todoList (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                description TEXT,
                creationDate DATETIME NOT NULL,
                deadline DATETIME,
                completionDate DATETIME,
                category TEXT NOT NULL,
                importance INTEGER NOT NULL)'
                )
  end

  private
  def self.db
    return @db if @db
    @db = SQLite3::Database.new('db/todoList.sqlite')
    @db.results_as_hash = true
    @db
  end
end

Seeder.seed!