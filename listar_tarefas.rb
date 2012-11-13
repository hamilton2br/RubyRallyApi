require 'rally_rest_api'

# 'Login to the Rally App'
@user_name = "your_login"
@password = "your_password"
@base_url = "https://rally1.rallydev.com/slm"

rally = RallyRestAPI.new(:base_url => @base_url, :username => @user_name, :password => @password)

it_result  = rally.find(:iteration) {equal :object_i_d, "7936115515"}

iteration = it_result.results.first

us_result = rally.find(:hierarchical_requirements) {equal :iteration, iteration}

us_result.each { |story| if  !story.tasks.nil? then story.tasks.each { |task| print  task.formatted_i_d + "," + task.state + "\n"} end }

de_result = rally.find(:defect) {equal :iteration, iteration}

de_result.each { |defect| if  !defect.tasks.nil? then defect.tasks.each { |task| print  task.formatted_i_d + "," + task.state + "\n"} end }
