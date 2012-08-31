require 'uri'

Given /^the CAS server accepts the credentials$/ do |table|
  table.hashes.each do |credentials|
    @cas.accept(credentials['username'], credentials['password'])
  end
end

Given /^a proxy callback$/ do
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
