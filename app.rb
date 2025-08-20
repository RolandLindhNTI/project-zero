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
    if session[:time] == nil
      session[:time] = Time.now.to_i
    end
    students = @db.execute("SELECT * from TE4")
    id = params[:id].to_i
    correct_id = params[:correct_id].to_i
    if session[:attempts].nil? && session[:score].nil?
        session[:attempts] = students.length
        session[:attempts_real] = 0
        session[:score] = 0
    end
        if students.length >= session[:attempts_real]
            if correct_id == id 
                if  session[:score] < session[:attempts]
                    session[:score] += 1
                    puts "#{session[:time]}" + "TIME TIME"
                end
            end
        end
    if session[:score] >= session[:attempts]
          puts "#{session[:time]}" + "TIME TIME"

      session[:time] = Time.now.to_i - session[:time]
        puts "#{session[:time]}" + "TIME TIME 2"

      redirect('/results')
    end
    redirect('/game')
end

get '/results' do
  puts "#{session[:time]}" + "TIME TIME"
  @time = session[:time].to_i
  @attempts = session[:attempts]
  @score = session[:score]
  slim :results
end