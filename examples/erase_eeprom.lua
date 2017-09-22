local ftdi = require 'luaftdi'

-- local ulUSBVendor, ulUSBProduct = 0x1939, 0x002c
-- local ulUSBVendor, ulUSBProduct = 0x0403, 0x6010
local ulUSBVendor, ulUSBProduct = 0x0640, 0x0028


local tVersionInfo = ftdi.get_library_version()
print(string.format("[FTDI version] major: %d, minor: %d, micro: %d, version_str: %s, snapshot_str: %s", tVersionInfo.major, tVersionInfo.minor, tVersionInfo.micro, tVersionInfo.version_str, tVersionInfo.snapshot_str))

-- Create a new FTDI context.
local tContext = ftdi.new()

-- Open the device.
local iResult = ftdi.usb_open(tContext, ulUSBVendor, ulUSBProduct)
if iResult~=0 then
  error('Failed to open the device!')
end

-- Read the EEPROM.
iResult = ftdi.read_eeprom(tContext)
if iResult~=0 then
  error('Failed to read the eeprom!')
end

-- Get the EEPROM size.
local iEepromSize
iResult, iEepromSize = ftdi.get_eeprom_value(tContext, ftdi.CHIP_SIZE)
if iResult~=0 then
  error('No EEPROM found.')
end
if iEepromSize==-1 then
  print(iResult, iEepromSize)
  error('The EEPROM is already empty.')
end

iResult = ftdi.erase_eeprom(tContext)
if iResult~=0 then
  error('Failed to erase the EEPROM.')
end

ftdi.free(tContext)
