require "bcrypt"

class App < Sinatra::Base
    def db
        return @db if @db

        @db = SQLite3::Database.new("db/todoList.sqlite")
        @db.results_as_hash = true

        return @db
    end

    configure do
        enable :sessions
        set :session_secret, SecureRandom.hex(64)
    end

    def check_access
        if !session[:user_id]
            p "Access denied"
            status 401
            redirect('/login')
        end

        p "user id: #{session[:user_id]}"
    end

    def get_username
        return db.execute('SELECT username FROM users WHERE id = ?', [session[:user_id]]).first['username'] if session[:user_id]

        return ""
    end
    
    get '/login' do
        erb(:"pages/login-page")
    end


    post '/login' do        
        input_username = params[:username]
        input_password = params[:password]
           
        user = db.execute('SELECT * FROM users WHERE username = ?', [input_username]).first;

        user_id = user['id'].to_i
        hashed_password = user['password'].to_s

        bcrypt_password = BCrypt::Password.new(hashed_password)

        if bcrypt_password == input_password
            session[:user_id] = user_id
            redirect('/')
        else
            status 401
            redirect('/login')
        end
    end
    
    get '/logout' do
        session.clear
        redirect('/login')
    end

    get '/create-account' do
        erb(:"pages/create-page")
    end

    post '/create-account' do
        username = params[:username]
        password = BCrypt::Password.create(params[:password])
        db.execute('INSERT INTO users (username, password) VALUES (?, ?)', [username, password])
        session[:user_id] = db.execute('SELECT id FROM users WHERE username = ?', [username]).first['id']
        redirect('/')
    end

    get '/' do
        check_access

        sort_option = ""
        sort = params[:sort]
        if sort == "Recent" || sort == nil
            sort_option = "ORDER BY id DESC"
        elsif sort == "Old"
            sort_option = "ORDER BY id ASC" 
        elsif sort == "Deadline (High - Low)"
            sort_option = "ORDER BY deadline DESC"
        elsif sort == "Deadline (Low - High)"
            sort_option = "ORDER BY deadline ASC"
        elsif sort == "Importance (High - Low)"
            sort_option = "ORDER BY importance DESC"
        elsif sort == "Importance (Low - High)"
            sort_option = "ORDER BY importance ASC"
        end

        show_option = ""
        show = params[:show]
        if show == nil || show == "Uncompleted"
            show_option = "WHERE completionDate IS NULL"
        elsif show == "Completed"
            show_option = "WHERE completionDate IS NOT NULL"
        elsif show == "All"
            show_option = ""
        end

        @todo = db.execute("SELECT * FROM tasks #{show_option} #{sort_option}")
        @categories = db.execute('SELECT DISTINCT category FROM tasks')

        # returns: string; either: seconds, minuts, houres, days, weeks, months, or years between the two times
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
        check_access

        @categories = db.execute('SELECT DISTINCT category FROM tasks')

        erb(:"pages/new_entry")
    end

    post '/new' do       
        check_access
        
        title = params[:title]
        description = params[:description]
        if params[:has_deadline]
            deadline = params[:deadline].sub!("T", " ")
        else
            deadline = nil
        end
        category = params[:category]
        importance = params[:importance]
        creationDate = DateTime.now.to_s.split('+')[0].sub!("T", " ")

        values = [session[:user_id], title, description, deadline, category, importance, creationDate]

        p values
        
        db.execute('INSERT INTO tasks (user_id, title, description, deadline, category, importance, creationDate) VALUES (?,?,?,?,?,?,?)', values)

        redirect("/")
    end

    get '/edit/:id' do | id |
        check_access

        @item = db.execute('SELECT * FROM tasks WHERE id = ?;', [id]).first
        @categories = db.execute('SELECT DISTINCT category FROM tasks')

        erb(:"pages/edit-item")
    end
    
    post '/edit/:id' do | id |
        check_access

        title = params[:title]
        description = params[:description]
        if params[:has_deadline]
            deadline = params[:deadline].sub!("T", " ")
        else
            deadline = nil
        end
        category = params[:category]
        importance = params[:importance]

        values = [title, description, deadline, category, importance, id]

        db.execute("UPDATE tasks SET title=?, description=?, deadline=?, category=?, importance=? WHERE id = ?", values)

        redirect("/")
    end

    get '/delete/:id' do | id |
        check_access

        db.execute("DELETE FROM tasks WHERE id = ?", [id])
        redirect("/")
    end

    get '/complete/:id' do | id |
        check_access

        time = DateTime.now.to_s.sub!("T", " ")
        db.execute('UPDATE tasks SET completionDate = ? WHERE id = ?', [time, id])

        redirect("/")
    end
 end
