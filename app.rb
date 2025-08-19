require "slim"
require "sinatra"
require "sqlite3"
require "sinatra/reloader"
require 'sinatra/flash' 
require_relative 'model.rb'

include Model

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
  students = @db.execute("SELECT * from TE4")

  correct_student = students.shuffle.first
  incorrect_students = (students - [correct_student]).sample(2)
  options = ([correct_student] + incorrect_students).shuffle

  slim :game, locals:{correct_student: correct_student, options: options}
end

post '/answer' do
    students = @db.execute("SELECT * from TE4")
    session[:attempts] ||= 0
    session[:score] ||= 0
    id = params[:id].to_i
    correct_id = params[:correct_id].to_i



    if students.length >= session[:attempts]

        if correct_id == id 
            session[:score] += 1
        else
            flash[:notice] = "wrong answer!"
        end
    end
    session[:attempts] += 1
    slim :game, locals:{score: session[:score], attempts: session[:attempts]}
    redirect('/game')
end