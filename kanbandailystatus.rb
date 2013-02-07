require 'rally_rest_api'
require 'ostruct'
require 'optparse'
require 'rubygems'
require 'gruff'

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
        iternames = options.iteration
end

#historias por scheduled state (todo os historico)
@storiesByScheduledState = Hash.new(Array.new)

###### construindo o hash para gerar o gráfico ###########

def BuildCFDHash(userStoryName, userStoryDescription)
	userStoryDescription.match('\[.*\]', userStoryDescription.index("to")) { |match| @storiesByScheduledState[match.to_s] += [userStoryName] } 
end

##########################################################

###### Atualizando o status do dia no historico ##########

def UpdateKanbamStatus
	File.open('dailystatus.txt', 'a') do |f|  
  		f.puts Date.today.to_s
		@storiesByScheduledState.each_pair { |key, values| f.puts key.to_s + "," + values.count.to_s }
		f.close
	end 
end

##########################################################

############ Construindo o gráfico CFD  ##################

def BuildCFDChart

	g = Gruff::Line.new
	g.title = "Cumulative Flow Diagram" 
	g.data("Apples", [1, 2, 3, 4, 4, 3])
	g.data("Oranges", [4, 8, 7, 9, 8, 9])
	g.data("Watermelon", [2, 3, 1, 5, 6, 8])
	g.data("Peaches", [9, 9, 10, 8, 7, 9])
	g.labels = {0 => '2003', 2 => '2004', 4 => '2005'}
	g.write("./CumulativeFlowDiagram.png")

end

##########################################################

# 'Login to the Rally App'
@user_name = options.user
@password = options.password
@base_url = "https://rally1.rallydev.com/slm"

num_defects = 0
num_histories = 0

plan_estimate_defects = 0
plan_estimate_histories = 0

rally = RallyRestAPI.new(:base_url => @base_url, :username => @user_name, :password => @password)

it_result  = rally.find(:iteration) {equal :object_i_d, iternames}

iteration = it_result.results.first

us_result = rally.find(:hierarchical_requirements) {equal :iteration, iteration}

us_result.each { |userStory| 
		userStory.revision_history.revisions.each { |revision| 
			revision.description.split(",").each { |description| 
					if !description.index("SCHEDULE STATE").nil? then BuildCFDHash(userStory.name, description) end
					print "." }
				}
	}

UpdateKanbamStatus()

BuildCFDChart()

puts "."

@storiesByScheduledState.each_pair { |key, values| print "-" + key.to_s + "\t" +
                                values.count.to_s + "\n"
                                values.each { |value| print "\t" + value + "\n"}
                                print "\n"
                           }
