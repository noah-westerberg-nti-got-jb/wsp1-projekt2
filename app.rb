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

        p "USER ID: #{session[:user_id]} HAS ENTERD"
    end

    def get_username
        return db.execute('SELECT username FROM users WHERE id = ?', [session[:user_id]]).first['username'] if session[:user_id]

        return ""
    end

    # returns category id if exists else creates new category and returns its id.
	def category_id(category_name, user_id)
        category_id = db.execute('SELECT category_id FROM categories WHERE category_name = ? AND user_id = ?', [category_name, user_id])
        if category_id != []
            category_id = category_id.first['category_id']
        else
            db.execute('INSERT INTO categories (category_name, user_id, background_color, text_color) VALUES (?,?, 0, 0)', [category_name, user_id])
            category_id = db.execute('SELECT category_id FROM categories WHERE category_name = ? AND user_id = ?', [category_name, user_id]).first['category_id']
        end
		return category_id
	end

    def get_subcategory_ids(category_id, categories)
        subcategories = [category_id]

        categories.each do |category|
          if category['parent_id'] == category_id
            subcategories.concat(get_subcategory_ids(category['category_id'], categories))
          end
        end

        return subcategories
    end

    def get_tasks(user_id, category_id, options)        
        # Get tasks from database
        all_tasks = [] 
        show_option = options['show']
        if show_option == nil || show_option == "" || show_option == "Uncompleted"
            all_tasks = db.execute('SELECT * FROM tasks JOIN categories ON tasks.category_id = categories.category_id WHERE tasks.user_id = ? AND tasks.completion_date IS NULL', [user_id])
        elsif show_option == "All"
            all_tasks = db.execute('SELECT * FROM tasks JOIN categories ON tasks.category_id = categories.category_id WHERE tasks.user_id = ?', [user_id])
        elsif show_option == "Completed"
            all_tasks = db.execute('SELECT * FROM tasks JOIN categories ON tasks.category_id = categories.category_id WHERE tasks.user_id = ? AND tasks.completion_date IS NOT NULL', [user_id])
        end

        # exit if there arn't any tasks
        if all_tasks == []
            return []
        end 

        tasks = []
        # get categories to include
        if category_id != nil
            all_categories = db.execute('SELECT category_id, parent_id FROM categories WHERE user_id = ?', [session[:user_id]])
            categories = get_subcategory_ids(category_id, all_categories)
            # select tasks with categories
            tasks = all_tasks.select {|task| categories.include?(task['category_id'])}
        else
            tasks = all_tasks
        end
        
        # sort tasks
        order_option = options['order']
        if order_option == "Recent" || order_option == nil
            tasks = tasks.sort_by { |task| 
                -task['id']
                }
        elsif order_option == "Old"
            tasks = tasks.sort_by {|task| task['id']}
        elsif order_option == "Deadline (Far - Close)"
            tasks = tasks.sort_by {|task| 
            if task['deadline'] != nil
              -DateTime.parse(task['deadline']).to_time.to_i
            else
                -1
            end
        }
        elsif order_option == "Deadline (Close - Far)"
            tasks = tasks.sort_by {|task| 
            if task['deadline'] != nil
              DateTime.parse(task['deadline']).to_time.to_i
            else
                (2**32 - 1)
            end}
        elsif order_option == "Importance (High - Low)"
            tasks = tasks.sort_by {|task| -task['importance']}
        elsif order_option == "Importance (Low - High)"
            tasks = tasks.sort_by {|task| task['importance']}
        end

        return tasks
    end

    def get_categories(user_id)
        return db.execute('SELECT DISTINCT category_name FROM categories WHERE user_id = ?', [user_id]).map {|category| category['category_name']}
    end
    
    get '/login' do
        erb(:"pages/login-page")
    end


    post '/login' do        
        input_username = params[:username]
        input_password = params[:password]
           
        user = db.execute('SELECT * FROM users WHERE username = ?', [input_username]).first;

        if user == nil
          redirect('/login')
        end

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
        erb(:"pages/create-user")
    end

    post '/create-account' do
        username = params[:username]
        password = BCrypt::Password.create(params[:password])
        if (db.execute('SELECT * FROM users WHERE username = ?', [username]) != [])
          redirect('/create-account')
        end
        db.execute('INSERT INTO users (username, password) VALUES (?, ?)', [username, password])
        session[:user_id] = db.execute('SELECT id FROM users WHERE username = ?', [username]).first['id']
        redirect('/')
    end

    get '/' do
        check_access

        user_id = session[:user_id]

        category = params[:category]
        if category == "All"
            category_id = nil
        else
            category_id = db.execute('SELECT category_id FROM categories WHERE category_name = ? AND user_id = ?', [category, user_id]).first['category_id'] if category != nil
        end

        options = {
            'show' => params[:show],
            'order' => params[:sort]
        }

        @todo = get_tasks(user_id, category_id, options)
        @categories = get_categories(user_id)

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

        @categories = get_categories(session[:user_id])

        erb(:"pages/new_entry")
    end

    post '/new' do       
        check_access
        
        user_id = session[:user_id]

        title = params[:title]
        description = params[:description]
        if params[:has_deadline]
            deadline = params[:deadline].sub!("T", " ")
        else
            deadline = nil
        end

        category = params[:category]
		category_id = category_id(category, user_id)

        importance = params[:importance]
        creation_date = DateTime.now.to_s.split('+')[0].sub!("T", " ")

        values = [user_id, title, description, deadline, category_id, importance, creation_date]

        db.execute('INSERT INTO tasks (user_id, title, description, deadline, category_id, importance, creation_date) VALUES (?,?,?,?,?,?,?)', values)

        redirect("/")
    end

    get '/edit/:id' do | id |
        check_access

        @item = db.execute('SELECT * FROM tasks WHERE id = ?;', [id]).first
        @categories = get_categories(session[:user_id])

        erb(:"pages/edit-item")
    end
    
    post '/edit/:id' do | id |
        check_access

		user_id = session[:user_id]

        title = params[:title]
        description = params[:description]
        if params[:has_deadline]      
            deadline = params[:deadline].sub!("T", " ")
        else
            deadline = nil
        end
        
		category = params[:category]
		category_id = category_id(category, user_id)

        importance = params[:importance]

        values = [title, description, deadline, category_id, importance, id]

        db.execute("UPDATE tasks SET title=?, description=?, deadline=?, category_id=?, importance=? WHERE id = ?", values)

        redirect("/")
    end

    get '/delete/:id' do | id |
        check_access

        db.execute("DELETE FROM tasks WHERE id = ?", [id])
        redirect("/")
    end

    get '/complete/:id/:is_completed' do | id, is_completed|
        check_access

        time = nil
        if is_completed.to_i == 0
            time = DateTime.now.to_s.sub!("T", " ")
        end

        db.execute('UPDATE tasks SET completion_date = ? WHERE id = ?', [time, id])

        redirect("/")
    end

    get '/categories' do
        check_access

        @categories = db.execute('SELECT * FROM categories WHERE user_id = ?', [session[:user_id]])

        @sorted_categories = @categories.sort_by {|category| category['category_id']}
        def get_nesting_level(parent_id)
            if parent_id == nil
                return 0
            end

             left = 0
             right = @sorted_categories.length - 1
             index = 0
             loop do
                index = left + (right - left) / 2
                search_id = @sorted_categories[index]['category_id']    
                break if search_id == parent_id

                if search_id > parent_id
                    right = index - 1
                else
                    left = index + 1
                end
          end

          return 1 + get_nesting_level(@sorted_categories[index]['parent_id'])
        end

        erb(:"pages/category-manager")
    end

    post '/update-categories' do 
        check_access

        category_hash = Hash.new

        category_array = params.map { |k, value|
            split_key = k.split("#")
            id = split_key[0]
            key = split_key[1]
            
            category_hash[id] = Hash.new

            [id, key, value]
        }.map { |id, key, value|
          category_hash[id][key] = value
        }

        category_hash.each do |id, values|
            if values['is_deleted'] == "true" && values['is_new'] == "false"
                db.execute('DELETE FROM categories WHERE category_id = ?', [id])
            end
        end

        category_hash = category_hash.select {|id, values|
            values['is_deleted'] == "false"
        }
        new_categories = category_hash.select{|id, values|
            values['is_new'] == "true"
        }

        # example:
        #   new_id_list {"new0" => 4, "new1" => 7, ...}
        new_id_list = Hash.new
        new_categories.each do |id, values|
            db.execute('INSERT INTO categories (user_id, category_name, background_color, text_color) VALUES (?, ?, ?, ?)', [session[:user_id], values['name'], 0, 0])
            new_id_list[id] = db.execute('SELECT category_id FROM categories WHERE user_id = ? AND category_name = ?', [session[:user_id], values['name']]).first['category_id']
        end

        category_hash.each do |id, values| 
            id = (id.include?("new")) ? new_id_list[id].to_i : id.to_i
            parent_id = values['parent_id']
            parent_id = (parent_id.include?("new")) ? new_id_list[parent_id] : parent_id
            parent_id = (parent_id == "") ? nil : parent_id.to_i
            name = values['name']
            text_color = values['text-color'].split("#")[1].to_i(16)
            background_color = values['background-color'].split("#")[1].to_i(16)

            db.execute('UPDATE categories SET category_name = ?, parent_id = ?, text_color = ?, background_color = ? WHERE category_id = ?', [name, parent_id, text_color, background_color, id])
        end

        redirect('/categories')
    end
 end