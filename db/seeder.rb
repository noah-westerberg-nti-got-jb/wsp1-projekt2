require 'sqlite3'

class Seeder
  
  def self.seed!
    drop_tables
    create_tables
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS tasks')
    db.execute('DROP TABLE IF EXISTS categories')
    db.execute('DROP TABLE IF EXISTS users')    
  end

  def self.create_tables
    db.execute('CREATE TABLE users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT NOT NULL UNIQUE,
                password TEXT NOT NULL)'
                )  
              
    db.execute('CREATE TABLE categories (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                category_name TEXT NOT NULL,
                parent_id INTEGER,
                color INTEGER NOT NULL)'
                )
      
    db.execute('CREATE TABLE tasks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                title TEXT NOT NULL,
                description TEXT,
                creationDate DATETIME NOT NULL,
                deadline DATETIME,
                completionDate DATETIME,
                category_id INTEGER NOT NULL,
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