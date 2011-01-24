Given /^a valid service ticket for "([^"]*)"$/ do |service|
  When %Q{a user requests a service ticket for "#{service}"}

  @st.present!

  @st.should be_ok
end

When /^that user requests a proxy ticket for "([^"]*)"$/ do |service|
  @st.retrieve_pgt!

  @pt = proxy_ticket(@st.pgt, service)
end

Then /^that proxy ticket should be valid$/ do
  @pt.present!

  @pt.should be_ok
end
