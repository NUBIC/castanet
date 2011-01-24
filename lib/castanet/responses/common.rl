%%{
  machine common;

  # Needed to support XML's character set, i.e. Unicode minus surrogate blocks.
  # See http://www.w3.org/TR/REC-xml/#charsets.
  alphtype int;

  # XML definitions
  # ---------------

  quote          = '"' | "'";

  # See http://www.w3.org/TR/REC-xml/#syntax.
  char_data      = [^<&]* - ([^<&]* "]]>" [^<&]*);

  # CAS definitions
  # ---------------
  
  # Section 3.7
  ticket_character = 'A' .. 'Z' | 'a' .. 'z' | '0' .. '9' | '-';
}%%
