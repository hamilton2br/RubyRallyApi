require 'rally_rest_api'
require 'ostruct'
require 'optparse'

#getting the options
options = OpenStruct.new
options.iteration = ""
options.user = nil
options.password = nil

opts = OptionParser.new
opts.banner = "Usage: listar_tarefas [options]"
opts.on('-iITERATION','--iteration=ITERATION','Iteration ID') do |iter|
        options.iteration << iter
end

opts.on('-U username','--user=username','Rally User') do |user|
        options.user = user
end
opts.on('-P password','--password=password','Rally Password') do |pass|
        options.password = pass
end

opts.on_tail( '-h', '--help', 'Displays this screen' ) do
        puts opts
        exit
end

opts.parse!(ARGV)

if options.iteration.empty? then
        puts opts
        exit
else
        itername = options.iteration
end

# 'Login to the Rally App'
@user_name = options.user
@password = options.password
@base_url = "https://rally1.rallydev.com/slm"

rally = RallyRestAPI.new(:base_url => @base_url, :username => @user_name, :password => @password)

it_result  = rally.find(:iteration) {equal :object_i_d, itername}

iteration = it_result.results.first

us_result = rally.find(:hierarchical_requirements) {equal :iteration, iteration}

us_result.each { |story| if  !story.tasks.nil? then story.tasks.each { |task| print  task.formatted_i_d + "," + task.state + "\n"} end }

de_result = rally.find(:defect) {equal :iteration, iteration}

de_result.each { |defect| if  !defect.tasks.nil? then defect.tasks.each { |task| print  task.formatted_i_d + "," + task.state + "\n"} end }
