require 'rally_rest_api'

# 'Login to the Rally App'
@user_name = "hamilton.fonte@abril.com.br"
@password = ".phantom2"
@base_url = "https://rally1.rallydev.com/slm"

num_defects = 0
num_histories = 0

plan_estimate_defects = 0
plan_estimate_histories = 0

rally = RallyRestAPI.new(:base_url => @base_url, :username => @user_name, :password => @password)

it_result  = rally.find(:iteration) {equal :object_i_d, "7936083278"}

iteration = it_result.results.first

#histórias
us_result = rally.find(:hierarchical_requirements) {equal :iteration, iteration}

us_result.each { |userStory| print ".\n"
				num_histories = num_histories + 1
				plan_estimate_histories = plan_estimate_histories + userStory.plan_estimate.to_i
		 }

#defeitos
def_result = rally.find(:defect) {equal :iteration, iteration}

def_result.each { |defect| print ".\n"
				num_defects = num_defects + 1
				plan_estimate_defects = plan_estimate_defects + defect.plan_estimate.to_i
		} 

puts "Historias: " + num_histories.to_s + "\t pontos: " + plan_estimate_histories.to_s
puts "Defeitos: " + num_defects.to_s + "\t pontos: " + plan_estimate_defects.to_s

puts "% de defeitos na sprint: " + format( "%.2f", ( num_defects.to_f/(num_defects + num_histories).to_f  )*100) + "%"
puts "% de pontos de defeitos na sprint: " + format( "%.2f", ( plan_estimate_defects/(plan_estimate_defects + plan_estimate_histories).to_f )*100) + "%"
