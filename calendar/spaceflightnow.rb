require 'net/http'
require 'date'
require 'digest'

get '/spaceflightnow' do

	uri = URI("https://spaceflightnow.com/launch-schedule/")
	res = Net::HTTP.get_response(uri)
	halt 502, {'Content-Type' => 'text/plain'}, res.body unless res.is_a?(Net::HTTPSuccess)
	
	html = res.body.force_encoding("utf-8")
	
	missions = html.scan(/<div class="datename">.+?<div class="missdescrip">.+?<\/div>/mu)
	
	missions.reverse.each do |mission|
		date = Date.parse(mission.match(/<span class="launchdate">(.+?)<\/span>/mu)[1].strip) rescue next
		name = mission.match(/<span class="mission">(.+?)<\/span>/)[1].strip
		time = mission.match(/\((\d{4}) UTC\)<BR>/m)[1].strip rescue next
		location = mission.match(/Launch site:<\/span>(.+?)<\/div>/)[1].strip
		description = mission.match(/<p>(.+?)<\/p>/m)[1].strip rescue ''

		datetime = date.to_s + 'T' + time[0,2] + ':' + time[2,2] + ':' + '00'

		@events.push({
			'uid'					=> Digest::MD5.hexdigest(name),
			'dtstart'			=> DateTime.parse(datetime),
			'summary'			=> name,
			'location'		=> location,
			'description'	=> description
		})

	end

end