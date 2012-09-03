require 'uri'

Given /^a proxy callback$/ do
  pending
end

When /^a user logs into CAS as "([^"]*)" \/ "([^"]*)"$/ do |username, password|
  get cas.url
  login_form = page.forms.first
  login_form.username = username
  login_form.password = password
  submit login_form
  page.body.should include("You have successfully logged in")
end
