Given /^a valid service ticket for "([^"]*)"$/ do |service|
  When %Q{a user requests a service ticket for "#{service}"}

  @st.present!

  @st.should be_valid
end

When /^that user requests a proxy ticket for "([^"]*)"$/ do |service|
  pgt = @st.pgt

  @pt = proxy_ticket(pgt, service)
end

Then /^that proxy ticket should be valid$/ do |service|
  @pt.present!

  @pt.should be_valid
end
