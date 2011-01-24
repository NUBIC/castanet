%%{
  machine common;

  # Needed to support XML's character set, i.e. Unicode minus surrogate blocks.
  # See http://www.w3.org/TR/REC-xml/#charsets.
  alphtype int;

  # Actions
  # -------

  action buffer { buffer << fc }

  # XML definitions
  # ---------------

  quote          = '"' | "'";

  # See http://www.w3.org/TR/REC-xml/#syntax.
  char_data      = [^<&]* - ([^<&]* "]]>" [^<&]*);

  # CAS definitions
  # ---------------

  # Section 3.7
  ticket_character = 'A' .. 'Z' | 'a' .. 'z' | '0' .. '9' | '-';
  ticket           = ticket_character*;

  # All service responses (Appendix A)
  service_response_start          = "<cas:serviceResponse xmlns:cas="
                                     quote
                                     "http://www.yale.edu/tp/cas"
                                     quote
                                     ">";
  service_response_end            = "</cas:serviceResponse>";

  # Error codes and reasons
  # -----------------------

  # No specific section or prescription, but the CAS protocol always writes
  # codes out with uppercase letters and underscores.
  failure_code    = ( ( upper | '_' ) @buffer )*;

  failure_reason  = char_data @buffer;
}%%
