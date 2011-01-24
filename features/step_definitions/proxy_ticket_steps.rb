Given /^a valid service ticket for "([^"]*)"$/ do |service|
  When %Q{a user requests a service ticket for "#{service}"}

  @st.present!

  @st.should be_ok
end

When /^that user requests a proxy ticket for "([^"]*)"$/ do |service|
  # We don't actually retrieve the proxy ticket or PGT here because some steps
  # expect part of the proxy ticket issuing process to raise an exception, and
  # it's easier to handle that in the pertinent steps rather than rolling it
  # all into this one step.  See the "proxy ticket should be valid" and
  # "request should fail" steps.
  @requested_service = service
end

Then /^that proxy ticket should be valid$/ do
  @st.retrieve_pgt!

  @pt = proxy_ticket(@st.pgt, @requested_service)

  @pt.present!

  @pt.should be_ok
end

Then /^the proxy ticket request should fail with "([^"]*)"$/ do |message|
  lambda do
    @st.retrieve_pgt!

    proxy_ticket(@st.pgt, @requested_service)
  end.should raise_error(Castanet::ProxyTicketError, /#{message}/)
end
