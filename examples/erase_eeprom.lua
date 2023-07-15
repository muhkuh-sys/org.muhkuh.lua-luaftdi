local ftdi = require 'luaftdi'

local ulUSBVendor, ulUSBProduct = 0x1939, 0x0023
-- local ulUSBVendor, ulUSBProduct = 0x1939, 0x002c
-- local ulUSBVendor, ulUSBProduct = 0x0403, 0x6010
-- local ulUSBVendor, ulUSBProduct = 0x0640, 0x0028


local tVersionInfo = ftdi.get_library_version()
print(string.format(
  "[FTDI version] major: %d, minor: %d, micro: %d, version_str: %s, snapshot_str: %s",
  tVersionInfo.major,
  tVersionInfo.minor,
  tVersionInfo.micro,
  tVersionInfo.version_str,
  tVersionInfo.snapshot_str
))

-- Create a new FTDI context.
local tContext = ftdi.Context()

-- Open the device.
local tResult, strError = tContext:usb_open(ulUSBVendor, ulUSBProduct)
assert(tResult, strError)

-- Get the Eeprom object.
local tEeprom = tContext:eeprom()
assert(tEeprom, 'Failed to get the Eeprom object.')

-- Read the EEPROM.
tResult, strError = tEeprom:read()
assert(tResult, strError)

-- Get the EEPROM size.
tResult, strError = tEeprom:get_value(ftdi.CHIP_SIZE)
assert(tResult, strError)
local iEepromSize = tResult
if iEepromSize==-1 then
  print('The EEPROM is already empty.')
end

tResult, strError = tEeprom:erase()
assert(tResult, strError)

print(tContext:usb_reset_device())

tContext:usb_close()
