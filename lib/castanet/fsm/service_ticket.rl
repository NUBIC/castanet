%%{
  machine parser;

  # Leaf tags
  # ---------

  code    = ( ( upper | '_' ) @buffer )+ %saveFailureCode;
  reason  = ( xmlContent @buffer )+ %saveFailureReason;
  pgtIou  = "<cas:proxyGrantingTicket>"
            ( ticketCharacter @buffer ){,256}
            "</cas:proxyGrantingTicket>" %savePgtIou;
  user    = "<cas:user>" ( xmlContent @buffer )+ %saveUsername "</cas:user>";

  # Non-leaf tags
  # -------------

  serviceResponseStart         = "<cas:serviceResponse xmlns:cas="
                                 quote
                                 "http://www.yale.edu/tp/cas"
                                 quote
                                 ">";
  serviceResponseEnd           = "</cas:serviceResponse>";

  authenticationFailureStart   = "<cas:authenticationFailure code="
                                 quote
                                 code
                                 quote
                                 ">";
  authenticationFailureEnd     = "</cas:authenticationFailure>";

  authenticationSuccessStart   = "<cas:authenticationSuccess>";
  authenticationSuccessEnd     = "</cas:authenticationSuccess>";


  # Top-level elements
  # ------------------

  ok_cas_st     = ( serviceResponseStart
                    space*
                    authenticationSuccessStart
                    space*
                    user
                    space*
                    pgtIou?
                    space*
                    authenticationSuccessEnd
                    space*
                    serviceResponseEnd ) @setAuthenticated;

  failed_cas_st = ( serviceResponseStart
                    space*
                    authenticationFailureStart
                    reason
                    authenticationFailureEnd
                    space*
                    serviceResponseEnd );

  cas_st        = ok_cas_st | failed_cas_st;
}%%
