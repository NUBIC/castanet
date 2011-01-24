%%{
  machine common;

  # XML definitions
  # ---------------
  quote       = '"' | "'";
  xml_content = any -- [<&];

  # CAS definitions
  # ---------------
  
  # Section 3.7
  ticket_character = 'A' .. 'Z' | 'a' .. 'z' | '0' .. '9' | '-';
}%%
