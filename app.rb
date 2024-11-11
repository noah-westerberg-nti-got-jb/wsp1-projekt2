class App < Sinatra::Base
    def db
        return @db if @db

        @db = SQLite3::Database.new("db/todoList.sqlite")
        @db.results_as_hash = true

        return @db
    end
    
    get '/' do
        erb(:"pages/index")
    end
    
    get '/new' do
        @categories = db.execute('SELECT DISTINCT category FROM todoList')

        erb(:"pages/new_entry")
    end

    post '/new' do        
        title = params['title']
        description = params['description']
        if params['has_deadline']
            deadline = params['deadline'].split("+")[0].sub!("T", " ")
        else
            deadline = nil
        end
        category = params['category']
        importance = params['importance']
        creationDate = DateTime.now.to_s.split('+')[0].sub!("T", " ")

        values = [title, description, deadline, category, importance, creationDate]
        p "values #{values}"
        
        db.execute('INSERT INTO todoList (title, description, deadline, category, importance, creationDate) VALUES (?,?,?,?,?,?)', values)

        redirect("/")
    end

end
