require 'uri'
require 'rack'

Given /^the CAS server accepts the credentials$/ do |table|
  table.hashes.each do |credentials|
    @cas.accept(credentials['username'], credentials['password'])
  end
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
  get URI.join(@cas.url, "/login?service=#{Rack::Utils.escape(service)}").tap { |x| puts x }

  @ticket = Rack::Utils.parse_query(URI.parse(page.uri.to_s).query)['ticket']
end

When /^the service ticket "([^"]*)" is checked for "([^"]*)"$/ do |ticket, service|
  @ticket = ticket
end

Then /^that service ticket should be valid for "([^"]*)"$/ do |service|
  client = Castanet::Client.new(:cas_url => @cas.url)

  client.valid_ticket?(@ticket, service).should be_true
end

Then /^that service ticket should not be valid for "([^"]*)"$/ do |service|
  client = Castanet::Client.new(:cas_url => @cas.url)

  client.valid_ticket?(@ticket, service).should be_false
end
