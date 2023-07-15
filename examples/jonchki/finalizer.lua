local t = ...

-- Copy all example files.
t:install{
  ['../eeprom_decode.lua']        = '${install_base}/',
  ['../eeprom_erase.lua']         = '${install_base}/',
  ['../eeprom_read_bin.lua']      = '${install_base}/',
  ['../eeprom_write_bin.lua']     = '${install_base}/',
  ['../list_all_devices.lua']     = '${install_base}/',
  ['../test_bitbang_input.lua']   = '${install_base}/',
  ['../test_bitbang_output.lua']  = '${install_base}/'
}

return true
