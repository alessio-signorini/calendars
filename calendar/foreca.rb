require 'net/http'
require 'json'
require 'digest'
require 'date'

#@events = []
get '/foreca' do
	uri = URI("https://api.foreca.net/mobile/105344750.json")

	query_params = {
		:lang		=> 'en',
		:version	=> '3',
		:v			=> '2.47.2.1'
	}
	uri.query = URI.encode_www_form(query_params)

	res = Net::HTTP.get_response(uri)
	halt 502, {'Content-Type' => 'text/plain'}, res.body unless res.is_a?(Net::HTTPSuccess)

	data = JSON.parse(res.body)

	data['hourly']['H3'].select{|x| x['time'].end_with?('08:00:00')}.each do |item|
		temp = 32 + (item['feels_like'] * (9.0/5))
		wind = item['wind_speed_max'] * 1.61

		icon = ['☀️','🌤️','⛅️','🌥️','☁️','☁️'][item['cloudiness']/20]
		icon = '💨' if wind > 14
		icon = (item['rain_probability'] > 50 ? '🌧️' : '🌦️') if item['rain_probability'] > 20

		@events.push({
			'uid'			=> Digest::MD5.hexdigest(item['time']),
			'dtstart'		=> DateTime.parse(item['time'][0,10]),
			'summary'		=> "#{icon}  #{temp.to_i}F #{wind.to_i}mph",
			'description'	=> JSON.pretty_generate(item) 
		})
	end

#	puts @events

end