require 'httparty'
require 'pdfkit'
require 'date'
require_relative './var.rb'

api_params = {:token => @my_token, :content => 'report',:report_id => '51087', :returnFormat => 'json', :type => 'flat',:format => 'json'}

response = HTTParty.post('https://redcap.ucsf.edu/api/', :body => api_params)

@histo = {}

ethnicity = ['Y', 'N','U']
race = ['AmerIndian/Alaska native','Asian','Hawaiian/Pac. Islander','Black','White','more than one','unknown/not reported']
sex = ['F','M']
course = ['NA','RR','SP','PP','PR','Other/Unsure']
infdis = ['N','Y']
tmnt = ['N','Y']
famms = ['N','Y']

summary = {}

@table = "<table>"
@table += "<tr><th>ID</th><th>Sex</th><th>Race</th><th>Hispanic</th><th>Dis. Duration</th><th>MS Course</th><th>Infectious Disease</th><th>MS Treatment</th><th>Family Hist. MS</th></tr>"

response.each do |record|
	begin
		@record_date = Date.parse(record['intake_form_timestamp'])
	rescue ArgumentError
		# puts "Invalid Date"
	end
	@today = DateTime.now
	@one_week_ago = @today - 7
	if @record_date && @record_date.between?(@one_week_ago, @today)
		pid = record['participant_id_intake']
		e = ethnicity[record['ethnicity'].to_i]
		r = race[record['race'].to_i]
		s = sex[record['sex'].to_i]
		dd = @today.year - record['year_diagnosed'].to_i
		dc = course[record['disease_course'].to_i]
		inf = infdis[record['infectious_disease'].to_i]
		dmt = tmnt[record['treatment_status'].to_i]
 		fam = famms[record['family_ms'].to_i]

		@table += "<tr>"

		@table += "<td align='center'>#{pid}</td>"
		@table += "<td align='center'>#{s}</td>"
		@table += "<td align='center'>#{r}</td>"
		@table += "<td align='center'>#{e}</td>"
		@table += "<td align='center'>#{dd}</td>"
		@table += "<td align='center'>#{dc}</td>"
		@table += "<td align='center'>#{inf}</td>"
		@table += "<td align='center'>#{dmt}</td>"
		@table += "<td align='center'>#{fam}</td>"

		@table += "</tr>"

		if !summary[r]
			summary[r] = {:hispanic_m => 0, :hispanic_f => 0, :nonhispanic_m => 0, :nonhispanic_f => 0}
		end
		if e == 'Y' && s == 'F'
			summary[r][:hispanic_f] += 1
		elsif e == 'Y' && s == 'M'
			summary[r][:hispanic_m] += 1
		elsif e == 'N' && s == 'F'
			summary[r][:nonhispanic_f] += 1
		elsif e == 'N' && s == 'M'
			summary[r][:nonhispanic_m] += 1
		end
	end
end
@table += "</table>"

@summary = "<table align='center'>"
@summary += "<tr><th>Race</th><th style='padding:10px;'>Hispanic<br>M/F</th><th style='padding:10px;'>Non-Hispanic<br>M/F</th>"

summary.each do |race, ethsex|
	@summary += "<tr>"
	@summary += "<td align='center'>#{race}</td>"
	@summary += "<td align='center'>#{ethsex[:hispanic_m]} / #{ethsex[:hispanic_f]}</td>"
	@summary += "<td align='center'>#{ethsex[:nonhispanic_m]} / #{ethsex[:nonhispanic_f]}</td>"
	@summary += "</tr>"
end

@summary += "</table>"

@header = "<h3>MS Genetics RedCap Intake Report #{@one_week_ago.strftime('%m/%d/%Y')} - #{@today.strftime('%m/%d/%Y')}</h3>"

@errata = "<h5>ID is the value from the redcap participant_id_intake field</h5>"

@html = "<html>"
@html += @header
@html += @summary
@html += "<br>"
@html += "<hr>"
@html += "<br>"
@html += @table
@html += @errata
@html += "</html>"

@file_date = @today.strftime("%m-%d-%Y")
PDFKit.new(@html, :page_size => 'Letter').to_file("./report.pdf")
