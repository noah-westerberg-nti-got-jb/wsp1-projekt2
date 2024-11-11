class App < Sinatra::Base
    def db
        return @db if @db

        @db = SQLite3::Database.new("db/todoList.sqlite")
        @db.results_as_hash = true

        return @db
    end
    
    get '/' do
        @todo = db.execute("SELECT * FROM todoList")

        # time1 - time2
        # returns: string; either: seconds, minuts, houres, days, weeks, months, years between the two times
        def time_difference(time1, time2)
            difference = time1 - time2
            difference_seconds = (difference.to_f * 86400).abs
            
            p time1
            p time2
            p difference_seconds
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
