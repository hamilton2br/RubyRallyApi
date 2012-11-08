require 'rally_rest_api'

# 'Login to the Rally App'
@user_name = "your_login"
@password = "your_password"
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
def GetTasksAndNewStatesFromFile()

	# Example 2 - Pass file to block
	File.open("tarefas.txt", "r") do |infile|
	    while (line = infile.gets)
		values = line.strip.split(',')
		UpdateTask(values[0],values[1])
	    end
	end
end
#############################################################

GetTasksAndNewStatesFromFile()

print "Tarefas alteradas com sucesso\n\n"
