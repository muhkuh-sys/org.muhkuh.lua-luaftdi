require 'muhkuh_cli_init'
local ftdi = require 'luaftdi'
local argparse = require 'argparse'


function hexdump(strData, uiBytesPerRow)
  local uiCnt
  local uiByteCnt
  local aDump


  if not uiBytesPerRow then
    uiBytesPerRow = 16
  end

  uiByteCnt = 0
  for uiCnt=1,strData:len() do
    if uiByteCnt==0 then
      aDump = { string.format("%08X :", uiCnt-1) }
    end
    table.insert(aDump, string.format(" %02X", strData:byte(uiCnt)))
    uiByteCnt = uiByteCnt + 1
    if uiByteCnt==uiBytesPerRow then
      uiByteCnt = 0
      print(table.concat(aDump))
    end
  end
  if uiByteCnt~=0 then
    print(table.concat(aDump))
  end
end


local tParser = argparse('FTDI EEPROM write bin', 'Write a bin file to an FTDI EEPROM.')
tParser:option('-i --infile')
  :description('Read the EEPROM contents from FILE.')
  :argname('<FILE>')
  :count(1)
  :target('strInputFileName')
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

local tFile = io.open(tArgs.strInputFileName, 'rb')
local strEepromData = tFile:read('*a')
tFile:close()

if string.len(strEepromData)~=256 then
  error('The EEPROM data has a strange size. It should have 256 bytes.')
end

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

--[[
-- Read the EEPROM.
tResult, strError = tEeprom:read()
assert(tResult, strError)

-- Get the EEPROM size.
tResult, strError = tEeprom:get_value(luaftdi.CHIP_SIZE)
assert(tResult, strError)
local iEepromSize = tResult
if iEepromSize~=-1 then
  tContext:usb_close()
  error('The EEPROM is not empty!')
end
--]]

tResult, strError = tEeprom:erase()
assert(tResult, strError)

tEeprom:initdefaults('Hilscher', 'dummy', 'dummy')

tResult, strError = tEeprom:erase()
assert(tResult, strError)

tResult, strError = tEeprom:build()
if tResult<0 then
  error('Failed to build the eeprom buffer.')
else
  print(string.format('Created EEPROM data with %d bytes.', tResult))
end

hexdump(strEepromData)
tResult, strError = tEeprom:set_buf(strEepromData)
assert(tResult, strError)

--[[
local strTest = tEeprom:get_buf()
if strTest~=strEepromData then
  error('Not equal!')
end
--]]

tResult, strError = tEeprom:write()
assert(tResult, strError)

tContext:usb_close()
