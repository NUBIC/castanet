%%{
  machine common;

  # XML definitions
  # ---------------
  quote       = '"' | "'";
  xmlContent  = any -- [<&];

  # CAS definitions
  # ---------------
  
  # Section 3.7
  ticketCharacter = 'A' .. 'Z' | 'a' .. 'z' | '0' .. '9' | '-';
}%%
