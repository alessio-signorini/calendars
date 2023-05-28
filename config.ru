require 'sinatra'
require 'icalendar'
require 'json'

before do
	@events = []
end

after do
	break unless @events.any?

	cal = Icalendar::Calendar.new

	@events.each do |event|
		e = Icalendar::Event.new

		e.uid				= event['uid']
		e.summary		= event['summary']
		e.dtstart 	= event['dtstart'].instance_of?(Date) ? Icalendar::Values::Date.new(event['dtstart']) : Icalendar::Values::DateTime.new(event['dtstart'], 'tzid' => 'UTC')
		e.dtend 		= Icalendar::Values::DateTime.new(event['dtend'], 'tzid' => 'UTC') if event['dtend']
		e.location	= event['location'] if event['location']
		e.description	=	event['description'] if event['description']

		cal.add_event(e)
	end

	status(200)
	headers('Content-type' => 'text/calendar')
	body(cal.to_ical)
end

require './calendar/corepower'
require './calendar/spaceflightnow'
require './calendar/foreca'

run Sinatra::Application
