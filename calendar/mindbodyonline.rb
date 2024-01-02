require 'net/http'
require 'date'
require 'digest'

#@events = []
get '/mindbodyonline' do

	uri = URI("https://widgets.mindbodyonline.com/widgets/schedules/203520/print")
	res = Net::HTTP.get_response(uri)
	halt 502, {'Content-Type' => 'text/plain'}, res.body unless res.is_a?(Net::HTTPSuccess)
	
	html = res.body.force_encoding("utf-8")
	
	classes = html.scan(/<tr class="\w+ DropIn hc_class filterable.+?<\/tr>/mu)
	
	classes.each do |item|
		id		= item.match(/<tr class="\w+ DropIn hc_class filterable.+?id="(\d+)"/mu)[1].strip
		date	= item.match(/class="hc_starttime" data-datetime="&quot;(\d\d\d\d-\d\d-\d\d)T.+?>/mu)[1].strip
		start	= item.match(/class="hc_starttime" data-datetime="&quot;\d\d\d\d-\d\d-\d\dT(\d\d:\d\d:\d\d).+?"/mu)[1].strip
		stop	= item.match(/class="hc_endtime" data-datetime="&quot;\d\d\d\d-\d\d-\d\dT(\d\d:\d\d:\d\d).+?"/mu)[1].strip
		name 	= item.match(/<a data-url="https:\/\/widgets.mindbodyonline.com\/widgets\/class_lists.+?>(.+?)<\/a>/)[1].strip
		trainer = item.match(/<a data-url="https:\/\/widgets.mindbodyonline.com\/widgets\/staff_lists.+?>(.+?)<\/a>/)[1].strip

		@events.push({
			'uid'			=> id,
			'dtstart'		=> DateTime.parse(date +'T' + start + '-07:00').new_offset(0),
			'dtend'			=> DateTime.parse(date +'T' + stop + '-07:00').new_offset(0),
			'summary'		=> name + ' (' + trainer + ')',
		})

	end

#	puts @events

end
