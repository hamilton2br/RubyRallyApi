require 'rally_rest_api'
require 'ostruct'
require 'optparse'

#getting the options
options = OpenStruct.new
options.iteration = ""
options.user = nil
options.password = nil

opts = OptionParser.new
opts.banner = "Usage: criar_tasks_v2 [options]"
opts.on('-iITERATION','--iteration=ITERATION','Iteration ID (mandatory)') do |iter|
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

#############################################################
# Create the tasks for a User Story			    #
#############################################################
def CreateTasksForUserStory (aUserStory, tasks)

	rally = RallyRestAPI.new(:base_url => @base_url, :username => @user_name, :password => @password)

	query_result = rally.find(:hierarchical_requirement) {equal :formatted_i_d, aUserStory}

	userStory = query_result.results.first

	tasks.each { |task| 

		fields = {
			    :work_product => userStory,
			    :name => task,
			    :state => "Defined",
			    :estimate => 1,
			    :to_do => 1
		}

		rally.create(:task, fields)

		print  aUserStory + ":" + task + " - OK\n"
	}
end
#############################################################

#############################################################
# Create the tasks for a Defect                             #
#############################################################
def CreateTasksForDefect (aDefect, tasks)

	rally = RallyRestAPI.new(:base_url => @base_url, :username => @user_name, :password => @password)

        query_result = rally.find(:defect) {equal :formatted_i_d, aDefect}

        defect = query_result.results.first

        tasks.each { |task|

                fields = {
                            :work_product => defect,
                            :name => task,
                            :state => "Defined",
                            :estimate => 1,
                            :to_do => 1
                }

                rally.create(:task, fields)

                print aDefect + ":" + task + " - OK\n"
        }
end
#############################################################

#############################################################
# 		Get the stories from file		    #
#############################################################
def GetUserStoriesAndTasksFromFile()

	File.open("novas_tarefas_v2.txt", "r") do |infile|

	    defect_tasks = Hash.new(Array.new)
	    us_tasks = Hash.new(Array.new)
	    work_product = ""

	    while (line = infile.gets)
		
		line = line.strip

		if (!work_product.match('\AUS').nil? && line.match('(\AUS|\ADE)').nil?) then us_tasks[work_product] += [line] end
		if (!work_product.match('\ADE').nil? && line.match('(\AUS|\ADE)').nil?) then defect_tasks[work_product] += [line] end
		if (!line.match('\AUS').nil? || !line.match('\ADE').nil?) then work_product = line end

	    end

	    us_tasks.each_pair { |us,values| CreateTasksForUserStory(us,values) }
	    defect_tasks.each_pair { |de,values| CreateTasksForDefect(de,values)  }
	
	end
end
#############################################################

GetUserStoriesAndTasksFromFile()

print "Tarefas criadas com sucesso\n\n"
