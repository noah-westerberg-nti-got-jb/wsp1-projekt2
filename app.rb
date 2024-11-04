class App < Sinatra::Base

    get '/' do
        erb(:"pages/index")
    end

end
