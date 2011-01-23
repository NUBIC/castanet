require 'uri'
require 'rack'

Given /^the CAS server accepts the credentials$/ do |table|
  table.hashes.each do |credentials|
    @cas.accept(credentials['username'], credentials['password'])
  end
end

Given /^a proxy callback$/ do
  pending
end

Given /^a valid service ticket for "([^"]*)"$/ do |service|
  pending
end

When /^a user logs into CAS as "([^"]*)" \/ "([^"]*)"$/ do |username, password|
  get @cas.url
  login_form = page.forms.first
  login_form.username = username
  login_form.password = password
  submit login_form
  page.body.should include("You have successfully logged in")
end

When /^(?:a user )?requests a service ticket for "([^"]*)"$/ do |service|
  # CAS servers will redirect to the requested service if they're able to issue
  # a service ticket for said service.  We don't want to Mechanize to follow
  # redirects because our scenarios use domains reserved for testing purposes.
  agent.redirect_ok = false

  get URI.join(@cas.url, "/login?service=#{Rack::Utils.escape(service)}").tap { |x| puts x }

  @st = Rack::Utils.parse_query(URI.parse(page.response['location']).query)['ticket']
end

When /^that user requests a proxy ticket for "([^"]*)"$/ do |service|
  pending
end

When /^the service ticket "([^"]*)" is checked for "([^"]*)"$/ do |ticket, service|
  @st = ticket
end

Then /^that proxy ticket should be valid for "([^"]*)"$/ do |service|
  pending
end

Then /^that service ticket should be valid for "([^"]*)"$/ do |service|
  ticket = service_ticket(@st, service)

  ticket.present!
  ticket.should be_valid
end

Then /^that service ticket should not be valid for "([^"]*)"$/ do |service|
  ticket = service_ticket(@st, service)

  ticket.present!
  ticket.should_not be_valid
end
