require 'muhkuh_cli_init'
local ftdi = require 'luaftdi'
local argparse = require 'argparse'

local tParser = argparse('FTDI EEPROM erase', 'Erase an FTDI EEPROM.')
tParser:option('-d --device')
  :description('Open the device with VID:PID.')
  :argname('<VID>:<PID>')
  :count(1)
  :convert(function(strArg)
    local tMatch = string.match(strArg, "(%x%x%x%x):(%x%x%x%x)")
      if tMatch==nil then
        return nil, string.format("The VID:PID definition has an invalid format: '%s'", strArg)
      else
        return strArg
      end
    end)
  :target('astrVidPid')

local tArgs = tParser:parse()

local strVID, strPID = string.match(tArgs.astrVidPid, "(%x%x%x%x):(%x%x%x%x)")
local ulUSBVendor = tonumber('0x' .. strVID)
local ulUSBProduct = tonumber('0x' .. strPID)


local tVersionInfo = ftdi.get_library_version()
print(string.format("[FTDI version] major: %d, minor: %d, micro: %d, version_str: %s, snapshot_str: %s", tVersionInfo.major, tVersionInfo.minor, tVersionInfo.micro, tVersionInfo.version_str, tVersionInfo.snapshot_str))

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
