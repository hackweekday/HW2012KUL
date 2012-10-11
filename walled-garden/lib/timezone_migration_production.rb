#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

require File.dirname(__FILE__) + "/../../config/application"
Rails.application.require_environment!

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  
  # Replace this with your code
  Rails.logger.auto_flushing = true
  Rails.logger.info "This daemon is still running at #{Time.now}.\n"
  require 'tzinfo'

  COUNTRIES =  [["Afghanistan", "AF"], ["Albania", "AL"], ["Algeria", "DZ"], ["American Samoa", "AS"], ["Andorra", "AD"], ["Angola", "AO"],  
		["Anguilla", "AI"], ["Antarctica", "AQ"], ["Antigua and Barbuda", "AG"], ["Argentina", "AR"], ["Armenia", "AM"], ["Aruba", "AW"],  
		["Australia", "AU"], ["Austria", "AT"], ["Azerbaidjan", "AZ"], ["Bahamas", "BS"], ["Bahrain", "BH"], ["Banglades", "BD"], ["Barbados", "BB"], 
		["Belarus", "BY"], ["Belgium", "BE"], ["Belize", "BZ"], ["Benin", "BJ"], ["Bermuda", "BM"], ["Bolivia", "BO"], ["Bosnia-Herzegovina", "BA"], 
		["Botswana", "BW"], ["Bouvet Island", "BV"], ["Brazil", "BR"], ["British Indian O. Terr.", "IO"], ["Brunei Darussalam", "BN"], ["Bulgaria", "BG"], 
		["Burkina Faso", "BF"], ["Burundi", "BI"], ["Buthan", "BT"], ["Cambodia", "KH"], ["Cameroon", "CM"], ["Canada", "CA"], ["Cape Verde", "CV"], 
		["Cayman Islands", "KY"], ["Central African Rep.", "CF"], ["Chad", "TD"], ["Chile", "CL"], ["China", "CN"], ["Christmas Island", "CX"], 
		["Cocos (Keeling) Isl.", "CC"], ["Colombia", "CO"], ["Comoros", "KM"], ["Congo", "CG"], ["Cook Islands", "CK"], ["Costa Rica", "CR"],  
		["Croatia", "HR"], ["Cuba", "CU"], ["Cyprus", "CY"], ["Czech Republic", "CZ"], ["Czechoslovakia", "CS"], ["Denmark", "DK"], ["Djibouti", "DJ"], 
		["Dominica", "DM"], ["Dominican Republic", "DO"], ["East Timor", "TP"], ["Ecuador", "EC"], ["Egypt", "EG"], ["El Salvador", "SV"], 
		["Equatorial Guinea", "GQ"], ["Estonia", "EE"], ["Ethiopia", "ET"], ["Falkland Isl.(UK)", "FK"], ["Faroe Islands", "FO"], ["Fiji", "FJ"],  
		["Finland", "FI"], ["France", "FR"], ["France (European Ter.)", "FX"], ["French Southern Terr.", "TF"], ["Gabon", "GA"], ["Gambia", "GM"],  
		["Georgia", "GE"], ["Germany", "DE"], ["Ghana", "GH"], ["Gibraltar", "GI"], ["Great Britain (UK)", "GB"], ["Greece", "GR"], ["Greenland", "GL"],  
		["Grenada", "GD"], ["Guadeloupe (Fr.)", "GP"], ["Guam (US)", "GU"], ["Guatemala", "GT"], ["Guinea", "GN"], ["Guinea Bissau", "GW"],  
		["Guyana", "GY"], ["Guyana (Fr.)", "GF"], ["Haiti", "HT"], ["Heard & McDonald Isl.", "HM"], ["Honduras", "HN"], ["Hong Kong", "HK"],  
		["Hungary", "HU"], ["Iceland", "IS"], ["India", "IN"], ["Indonesia", "ID"], ["Iran", "IR"], ["Iraq", "IQ"], ["Ireland", "IE"], ["Israel", "IL"],  
		["Italy", "IT"], ["Ivory Coast", "CI"], ["Jamaica", "JM"], ["Japan", "JP"], ["Jordan", "JO"], ["Kazachstan", "KZ"], ["Kenya", "KE"],  
		["Kirgistan", "KG"], ["Kiribati", "KI"], ["Korea (North)", "KP"], ["Korea (South)", "KR"], ["Kuwait", "KW"], ["Laos", "LA"], ["Latvia", "LV"],  
		["Lebanon", "LB"], ["Lesotho", "LS"], ["Liberia", "LR"], ["Libya", "LY"], ["Liechtenstein", "LI"], ["Lithuania", "LT"], ["Luxembourg", "LU"],  
		["Macau", "MO"], ["Madagascar", "MG"], ["Malawi", "MW"], ["Malaysia", "MY"], ["Maldives", "MV"], ["Mali", "ML"], ["Malta", "MT"],  
		["Marshall Islands", "MH"], ["Martinique (Fr.)", "MQ"], ["Mauritania", "MR"], ["Mauritius", "MU"], ["Mexico", "MX"], ["Micronesia", "FM"],  
		["Moldavia", "MD"], ["Monaco", "MC"], ["Mongolia", "MN"], ["Montserrat", "MS"], ["Morocco", "MA"], ["Mozambique", "MZ"], ["Myanmar", "MM"],  
		["Namibia", "NA"], ["Nauru", "NR"], ["Nepal", "NP"], ["Netherland Antilles", "AN"], ["Netherlands", "NL"], ["Neutral Zone", "NT"],  
		["New Caledonia (Fr.)", "NC"], ["New Zealand", "NZ"], ["Nicaragua", "NI"], ["Niger", "NE"], ["Nigeria", "NG"], ["Niue", "NU"],  
		["Norfolk Island", "NF"], ["Northern Mariana Isl.", "MP"], ["Norway", "NO"], ["Oman", "OM"], ["Pakistan", "PK"], ["Palau", "PW"],  
		["Panama", "PA"], ["Papua New", "PG"], ["Paraguay", "PY"], ["Peru", "PE"], ["Philippines", "PH"], ["Pitcairn", "PN"], ["Poland", "PL"],  
		["Polynesia (Fr.)", "PF"], ["Portugal", "PT"], ["Puerto Rico (US)", "PR"], ["Qatar", "QA"], ["Reunion (Fr.)", "RE"], ["Romania", "RO"],  
		["Russian Federation", "RU"], ["Rwanda", "RW"], ["Saint Lucia", "LC"], ["Samoa", "WS"], ["San Marino", "SM"], ["Saudi Arabia", "SA"],  
		["Senegal", "SN"], ["Seychelles", "SC"], ["Sierra Leone", "SL"], ["Singapore", "SG"], ["Slovak Republic", "SK"], ["Slovenia", "SI"],  
		["Solomon Islands", "SB"], ["Somalia", "SO"], ["South Africa", "ZA"], ["Soviet Union", "SU"], ["Spain", "ES"], ["Sri Lanka", "LK"],  
		["St. Helena", "SH"], ["St. Pierre & Miquelon", "PM"], ["St. Tome and Principe", "ST"], ["St.Kitts Nevis Anguilla", "KN"],  
		["St.Vincent & Grenadines", "VC"], ["Sudan", "SD"], ["Suriname", "SR"], ["Svalbard & Jan Mayen Is", "SJ"], ["Swaziland", "SZ"], ["Sweden", "SE"],  
		["Switzerland", "CH"], ["Syria", "SY"], ["Tadjikistan", "TJ"], ["Taiwan", "TW"], ["Tanzania", "TZ"], ["Thailand", "TH"], ["Togo", "TG"],  
		["Tokelau", "TK"], ["Tonga", "TO"], ["Trinidad & Tobago", "TT"], ["Tunisia", "TN"], ["Turkey", "TR"], ["Turkmenistan", "TM"],  
		["Turks & Caicos Islands", "TC"], ["Tuvalu", "TV"], ["Uganda", "UG"], ["Ukraine", "UA"], ["United Arab Emirates", "AE"], ["United Kingdom", "GB"], 
		["United States", "US"], ["Uruguay", "UY"], ["US Minor outlying Isl.", "UM"], ["Uzbekistan", "UZ"], ["Vanuatu", "VU"], ["Vatican City State", "VA"],  
		["Venezuela", "VE"], ["Vietnam", "VN"], ["Virgin Islands (British)", "VG"], ["Virgin Islands (US)", "VI"], ["Wallis & Futuna Islands", "WF"],  
		["Western Sahara", "EH"], ["Yemen", "YE"], ["Yugoslavia", "YU"], ["Zaire", "ZR"], ["Zambia", "ZM"], ["Zimbabwe", "ZW"]]

	COUNTRIES.each do |c|
		puts c[1]
		begin
			tz = TZInfo::Country.get(c[1])
		rescue
			puts "nil"
			TimeZone.create(:country => c[0], :country_code => c[1])
			next
		end
		tz.zone_names.each do |x|
			#Time.now = x
			puts "#{x} #{Time.now.in_time_zone(x)}"
			tz = Time.now.in_time_zone(x).to_s.split(" ")[2]
			puts tz
			TimeZone.create(:country => c[0], :country_code => c[1], :zone_name => x, :time_zone => tz)
		end
	end
  
  exit
end
