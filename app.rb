require "slim"
require "sinatra"
require "sqlite3"
require "sinatra/reloader"
require 'sinatra/flash' 
require_relative 'model.rb'
require 'debug'

include Model



configure do
    enable :sessions
    set :session_secret, "supersecret"

end


before do
    @db = database()
end

error 404 do
    flash[:notice] = "Route does not exist"
    redirect('/')
end

get('/') do
    @result = @db.execute("SELECT * FROM TE4")
    slim(:index)
end

get '/game' do
    puts session[:attempts]
    puts session[:score]
  students = @db.execute("SELECT * from TE4")

  correct_student = students.shuffle.first
  incorrect_students = (students - [correct_student]).sample(2)
  options = ([correct_student] + incorrect_students).shuffle
    @attempts = session[:attempts]
    @score = session[:score]
  slim :game, locals:{correct_student: correct_student, options: options}
end

post '/answer' do
    students = @db.execute("SELECT * from TE4")
    id = params[:id].to_i
    correct_id = params[:correct_id].to_i
    if session[:attempts].nil? && session[:score].nil?
        session[:attempts] = 0
        session[:score] = 0
    end
    if students.length >= session[:attempts]
        if correct_id == id 
            p session[:score]
            session[:score] = 150
            p session[:score]
        end
        p session[:score]
    end
    p "end of line"
    p session[:attempts]
    session[:attempts] = 100
    p session[:attempts]
    redirect('/game')
end