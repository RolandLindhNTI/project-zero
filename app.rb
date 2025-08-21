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
  @show_normal_leaderboard = @db.execute("SELECT * FROM leaderboard_normal ORDER BY score DESC, time ASC LIMIT 10")
  @show_hard_leaderboard = @db.execute("SELECT * FROM leaderboard_hard ORDER BY score DESC, time ASC LIMIT 10")

  slim(:index)
end

get '/game/:difficulty' do
  @difficulty = params[:difficulty].to_sym
  session[:difficulty] = @difficulty

  if @difficulty == :normal
    p "INNE I IF SATS"
    students = @db.execute("SELECT * from game_class")

    correct_student = students.shuffle.first
    while correct_student["bild"] == nil
      correct_student = students.shuffle.first
    end
    incorrect_students = (students - [correct_student]).sample(2)
    options = ([correct_student] + incorrect_students).shuffle
    @attempts = session[:attempts]
    @score = session[:score]

    return slim :game, locals:{correct_student: correct_student, options: options, difficulty: @difficulty}
  
  end

  if @difficulty == :hard
    students = @db.execute("SELECT * from game_class")

    correct_student = students.shuffle.first
    while correct_student["bild"] == nil
      correct_student = students.shuffle.first
    end

    @attempts = session[:attempts]
    @score = session[:score]


    return slim :game, locals:{correct_student: correct_student, students: students, difficulty: @difficulty}
  end

end

post '/answer' do
    if session[:time] == nil
      session[:time] = Time.now.to_i
    end

    students = @db.execute("SELECT * from game_class")

    id = params[:id]
    correct_id = params[:correct_id]
    correct_name = params[:namn]
    if session[:difficulty] == :normal
      id = id.to_i
      correct_id = correct_id.to_i
    end
    puts id

    if session[:attempts].nil? && session[:score].nil?
        session[:attempts] = students.length
        session[:attempts_real] = 0
        session[:score] = 0
    end

    if students.length >= session[:attempts_real]
        if correct_id == id 
          if  session[:score] < session[:attempts]
              session[:score] += 1
          end

        
        elsif id.class == String && session[:score] < session[:attempts]
          if id.downcase == correct_name.downcase
            session[:score] += 1
          end
        end
    end

    session[:attempts_real] += 1
    @db.execute("UPDATE game_class SET bild = NULL WHERE id = ?", correct_id)

    if students.length == session[:attempts_real]

        session[:time] = Time.now.to_i - session[:time]

      redirect('/results')
    end

    redirect("/game/#{session[:difficulty]}")
end

get '/results' do
  @time = session[:time].to_i
  @attempts = session[:attempts]
  @score = session[:score]

  slim :results
end

post '/results' do
  name = params[:player_name]

  @time = session[:time].to_i
  @attempts = session[:attempts]
  @score = session[:score]
  @db.execute("INSERT INTO leaderboard_"+"#{session["difficulty"]}"" (namn,score,attempts,time) VALUES (?,?,?,?)", [name,@score,@attempts,@time])

  redirect '/restart'
end

get '/restart' do
  session.clear
  @db.execute("DELETE FROM game_class")
  @db.execute("INSERT INTO game_class SELECT * FROM TE4")

  redirect '/'
end