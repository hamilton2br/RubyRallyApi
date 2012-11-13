require 'rally_rest_api'
require 'date'

# 'Login to the Rally App'
@user_name = "your_login"
@password = "your_password"
@base_url = "https://rally1.rallydev.com/slm"
@statistics = Hash.new()
@addedTasksByTag = Hash.new(Array.new)

#############################################################
# To get the tasks that entered the sprint after it started #
#############################################################
def BuildStoryStatistics (aUserStory)

	print ".\n"
	numTasks = aUserStory.tasks.count
	numAddedTasks = 0

	aUserStory.tasks.each 	{ |task|
					tDate = Date.parse(task.creation_date.to_s)
					iDate = Date.parse(task.iteration.start_date.to_s)
				 
					if (tDate.to_time.to_i - iDate.to_time.to_i > 0) then 
						#task foi criada depois do inicio da sprint
						if task.tags.nil? then
							#adicionar a tarefas sem tag
                                                        @addedTasksByTag["No Tag"] += [task.name]
						else
							#adicionar a tarefas por tags
                                                        task.tags.each { |tag| @addedTasksByTag[tag.name] += [task.name] }
						end

						numAddedTasks = numAddedTasks + 1
					end
				} 

	@statistics[aUserStory.formatted_i_d + "-" + aUserStory.name] = [numTasks,numAddedTasks, format("%.2f",(numAddedTasks.to_f/numTasks.to_f)*100)]
	@statistics["Totais"][0] = @statistics["Totais"][0] + numTasks
	@statistics["Totais"][1] = @statistics["Totais"][1] + numAddedTasks
	@statistics["Totais"][2] = format("%.2f", (@statistics["Totais"][1].to_f/@statistics["Totais"][0].to_f)*100)
	
end
#############################################################


rally = RallyRestAPI.new(:base_url => @base_url, :username => @user_name, :password => @password)

@statistics["Totais"] = [0,0,"0"]

it_result  = rally.find(:iteration) {equal :object_i_d, "7936115515"}

iteration = it_result.results.first

us_result = rally.find(:hierarchical_requirements) {equal :iteration, iteration}

us_result.each { |userStory| BuildStoryStatistics(userStory) }

# Imprimindo resultados, objetivo eh gerar PDF

@statistics.each_key { |key|  print "\n" + key + "\n\t" + "Total Tarefas: " + @statistics[key][0].to_s + "\n\t" + 
					"Tarefas Adicionadas: " + @statistics[key][1].to_s + "\n\t" + 
					"% alteracao: " + @statistics[key][2] + "\n\n" }
puts "Tarefas adicionadas por tag:\n"

@addedTasksByTag.each_pair { |key, values| print key + "\t" + 
				values.count.to_s + "\t" + format("%.2f", (values.count.to_f/@statistics["Totais"][1].to_f)*100) + "\n" }
