require 'net/http'

get '/corepower' do
	hostname = ENV['COREPOWER_HOSTNAME'] || 'ijx69mqhxg.execute-api.us-west-1.amazonaws.com'

	uri = URI("https://#{hostname}/main/schedules")

	query_params = {
		:start_date => Date.today,
		:end_date => Date.today + (14 - Date.today.cwday),
		:studios => 'd0507acb-9b11-4fac-8498-759d40b4c203,cbece72f-5a14-4df4-a37d-c153f1d4a81d'
	}
	uri.query = URI.encode_www_form(query_params)

	res = Net::HTTP.get_response(uri)
	halt 502, {'Content-Type' => 'text/plain'}, res.body unless res.is_a?(Net::HTTPSuccess)
	
	types_to_hide = params['exclude'].upcase.split(',') rescue []

	data = JSON.parse(res.body)

	data['sessions'].each do |session|
		next unless session['available_slots'] > 0

		type = session['name'].match('\b[A-Z][A-Z0-9\.]+')[0] rescue nil
			next if type && types_to_hide.any? && types_to_hide.include?(type)

		@events.push({
			'uid'				=> session['session_guid'],
			'dtstart'		=> DateTime.parse(session['start_time_utc']),
			'dtend'			=> DateTime.parse(session['end_time_utc']),
			'location'	=> session['center_name'],
			'summary'		=> session['name'] + ' (' + session['available_slots'].to_s + ')'
		})
	end

end