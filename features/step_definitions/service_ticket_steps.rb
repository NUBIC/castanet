require 'uri'
require 'rack'

When /^(?:a user )?requests a service ticket for "([^"]*)"$/ do |service|
  # CAS servers will redirect to the requested service if they're able to issue
  # a service ticket for said service.  We don't want to Mechanize to follow
  # redirects because our scenarios use domains reserved for testing purposes.
  agent.redirect_ok = false

  get URI.join(cas_url, "/login?service=#{Rack::Utils.escape(service)}")

  query = URI.parse(page.response['location']).query

  @cas_ticket = Rack::Utils.parse_query(query)['ticket']
  @st = service_ticket(@cas_ticket, service)
end

When /^presents the service ticket to "([^"]*)"$/ do |service|
  @st = service_ticket(@cas_ticket, service)
end

When /^the service ticket "([^"]*)" is checked for "([^"]*)"$/ do |ticket, service|
  @st = service_ticket(ticket, service)
end

Then /^that service ticket should be valid$/ do
  @st.present!

  @st.should be_ok
end

Then /^that service ticket should not be valid$/ do
  @st.present!

  @st.should_not be_ok
end
