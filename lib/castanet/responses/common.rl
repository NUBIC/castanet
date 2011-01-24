%%{
  machine common;

  # Needed to support XML's character set, i.e. Unicode minus surrogate blocks.
  # See http://www.w3.org/TR/REC-xml/#charsets.
  alphtype int;

  # XML definitions
  # ---------------
  quote       = '"' | "'";
  xml_content = any -- [<&];

  # CAS definitions
  # ---------------
  
  # Section 3.7
  ticket_character = 'A' .. 'Z' | 'a' .. 'z' | '0' .. '9' | '-';
}%%
