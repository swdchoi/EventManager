require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'

puts 'Event Manager Initialized!'

def cleaned_code (zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode (zipcode)

    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    response = civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    )

    response = response.officials
  rescue

  'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'

  end
end

def cleand_phone (phone)
  
  numbers = "0".."9"
  phonearrun = phone.gsub(/\s+/, "").split("")

  for num in phonearrun
    if numbers.include?(num) == false 
      phonearrun.delete(num)
    end
  end

  phonearrun = phonearrun
  
  if phonearrun.length == 11 && phonearrun[0] == 1
    phonearrun = phonearrun[1..10].join("")
  elsif phonearrun.length >= 11
    phonearrun = "bad number"
  elsif phonearrun.length < 10
    phonearrun = "bad number"
  elsif phonearrun.length == 10
    phonearrun = phonearrun.join("")
  end
  
end

def classifydatetime (datetime)
  Time.strptime(datetime, "%m/%d/%y %H:%M")
end

content = CSV.open('event_attendees.csv', headers: true, header_converters: :symbol)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

times = []

content.each do |row|

  id = row[0]

  name = row[:first_name]

  phone = cleand_phone(row[:homephone])

  zipcode = cleaned_code(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode) 

  form_letter = erb_template.result(binding)

  registration = row[:regdate]

  date = classifydatetime(registration)

  times << date 
  
  # Dir.mkdir('output') unless Dir.exist?('output')
  
  # filename = "output/thank_#{id}.html"

  # File.open(filename, 'w') do |file|
  #   file.puts form_letter
  # end

end

puts "_______________"

time = times.map{|a| a.hour}
puts time.tally
#Best time is 16:00!

puts "_______________"
date = times.map{|a| "#{Date.new(a.year, a.month, a.day).wday}"}
#Best date is Wednesday!
puts date.tally