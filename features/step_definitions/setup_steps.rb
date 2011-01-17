Given /^the CAS server accepts the credentials$/ do |table|
  table.hashes.each do |credentials|
    $cas.accept(credentials['username'], credentials['password'])
  end
end

Given /^a CAS\-protected application at "([^"]*)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end
