require 'rally_rest_api'
require 'ostruct'
require 'optparse'

#getting the options
options = OpenStruct.new
options.iteration = ""
options.user = nil
options.password = nil

opts = OptionParser.new
opts.banner = "Usage: atualizar_tasks [options]"
opts.on('-iITERATION','--iteration=ITERATION','Iteration ID') do |iter|
        options.iteration << iter
end

opts.on('-U username','--user=username','Rally User') do |user|
        options.user = user
end
opts.on('-P password','--password=password','Rally Password') do |pass|
        options.password = pass
end
opts.on('-F file','--file=file','File where the tasks and status are') do |file|
	options.file = file
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
@rally = RallyRestAPI.new(:base_url => @base_url, :username => @user_name, :password => @password)

#############################################################
# Update a Task Status					    #
#############################################################
def UpdateTask (task, state)

	query_result = @rally.find(:task) {equal :formatted_i_d, task}

	print "atualizando task " + task

	aTask = query_result.results.first

	if !aTask.nil? then
		print " ... "		
		fields = { :state => state  }
        	aTask.update(fields)
	end

	print " atualizado\n"

end
#############################################################


#############################################################
# 		Get tasks and states from file		    #
#############################################################
def GetTasksAndNewStatesFromFile(taskFile)

	# Example 2 - Pass file to block
	File.open(taskFile, "r") do |infile|
	    while (line = infile.gets)
		values = line.strip.split(',')
		UpdateTask(values[0],values[1])
	    end
	end
end
#############################################################

GetTasksAndNewStatesFromFile(options.file)

print "Tarefas alteradas com sucesso\n\n"
