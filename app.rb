class App < Sinatra::Base
    def db
        return @db if @db

        @db = SQLite3::Database.new("db/todoList.sqlite")
        @db.results_as_hash = true

        return @db
    end
    
    get '/' do
        @todo = db.execute("SELECT * FROM todoList WHERE completionDate IS NULL")

        # time1 - time2
        # returns: string; either: seconds, minuts, houres, days, weeks, months, years between the two times
        def time_difference(time1, time2)
            difference = time1 - time2
            difference_seconds = (difference.to_f * 86400).abs
            
            end_s = ""

            if difference_seconds < 60
                seconds = (difference * 86400).to_i
                if seconds > 1
                end_s = "s"
                end
                return "#{seconds} second" + end_s
            elsif difference_seconds < 3600
                minuts = (difference * 1440).to_i
                if minuts > 1
                    end_s = "s"
                end
                return "#{minuts} minut" + end_s
            elsif difference_seconds < 86400
                hours = (difference * 24).to_i
                if hours > 1
                    end_s = "s"
                end
                return "#{hours} hour" + end_s
            elsif difference.to_i < 365
                days = difference.to_i
                if days > 1
                    end_s = "s"
                end
                return "#{days} day" + end_s
            else
                years = (difference / 365).to_i
                if years > 1
                    end_s = "s"
                end
                return "#{years} year" + end_s
            end
        end

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
            deadline = params['deadline'].sub!("T", " ")
        else
            deadline = nil
        end
        category = params['category']
        importance = params['importance']
        creationDate = DateTime.now.to_s.split('+')[0].sub!("T", " ")

        values = [title, description, deadline, category, importance, creationDate]
        
        db.execute('INSERT INTO todoList (title, description, deadline, category, importance, creationDate) VALUES (?,?,?,?,?,?)', values)

        redirect("/")
    end

    get '/edit/:id' do | id |
      @item = db.execute('SELECT * FROM todoList WHERE id = ?;', [id])[0]
      @categories = db.execute('SELECT DISTINCT category FROM todoList')

      p @item['deadline']
        
      erb(:"pages/edit-item")
    end
    
    post '/edit/:id' do | id |
        title = params['title']
        description = params['description']
        if params['has_deadline']
            deadline = params['deadline'].sub!("T", " ")
        else
            deadline = nil
        end
        category = params['category']
        importance = params['importance']

        values = [title, description, deadline, category, importance, id]

        db.execute("UPDATE todoList SET title=?, description=?, deadline=?, category=?, importance=? WHERE id = ?", values)

        redirect("/")
    end

    get '/delete/:id' do | id |
        db.execute("DELETE FROM todoList WHERE id = ?", [id])
        redirect("/")
    end

    get '/complete/:id' do | id |
        time = DateTime.now.to_s.sub!("T", " ")
        db.execute('UPDATE todoList SET completionDate = ? WHERE id = ?', [time, id])

        redirect("/")
    end
 end
