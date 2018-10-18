require 'muhkuh_cli_init'
local ftdi = require 'luaftdi'
local argparse = require 'argparse'

local tParser = argparse('FTDI EEPROM decoder', 'Decode the contents of an FTDI EEPROM, optionally to a file.')
tParser:option('-o --outfile')
  :description('Write the EEPROM contents to FILE.')
  :argname('<FILE>')
  :target('strOutputFileName')
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
print()
print('Decoding EEPROM:')
tResult, strError = tEeprom:decode(1)
print()
assert(tResult, strError)

-- Get the vendor and product strings.
-- NOTE: The strings are padded with 0x00 bytes at the end. Cut them off or all further string operations will have problems.
local strVendor = tEeprom:get_manufacturer()
while string.byte(strVendor, -1)==0 do
  strVendor = string.sub(strVendor, 1, -2)
end
local strProduct = tEeprom:get_product()
while string.byte(strProduct, -1)==0 do
  strProduct = string.sub(strProduct, 1, -2)
end

hexdump(strVendor)
hexdump(strProduct)


print(string.format('Vendor: "%s"', strVendor))
print(string.format('Product: "%s"', strProduct))

local atValues = {
  { id=ftdi.VENDOR_ID, name='VENDOR_ID' },
  { id=ftdi.PRODUCT_ID, name='PRODUCT_ID' },
  { id=ftdi.RELEASE_NUMBER, name='RELEASE_NUMBER' },

  { id=ftdi.SELF_POWERED, name='SELF_POWERED' },
  { id=ftdi.REMOTE_WAKEUP, name='REMOTE_WAKEUP' },
  -- Battery powered?
  { id=ftdi.MAX_POWER, name='MAX_POWER' },

  { id=ftdi.IN_IS_ISOCHRONOUS, name='IN_IS_ISOCHRONOUS' },
  { id=ftdi.OUT_IS_ISOCHRONOUS, name='OUT_IS_ISOCHRONOUS' },
  { id=ftdi.SUSPEND_PULL_DOWNS, name='SUSPEND_PULL_DOWNS' },

  { id=ftdi.USE_SERIAL, name='USE_SERIAL' },
  { id=ftdi.USE_USB_VERSION, name='USE_USB_VERSION' },
  { id=ftdi.USB_VERSION, name='USB_VERSION' },

  { id=ftdi.CHIP_TYPE, name='CHIP_TYPE' },
  { id=ftdi.CHIP_SIZE, name='CHIP_SIZE' },

  { id=ftdi.HIGH_CURRENT, name='HIGH_CURRENT' },
  { id=ftdi.HIGH_CURRENT_A, name='HIGH_CURRENT_A' },
  { id=ftdi.HIGH_CURRENT_B, name='HIGH_CURRENT_B' },

  { id=ftdi.CHANNEL_A_RS485, name='CHANNEL_A_RS485' },
  { id=ftdi.CHANNEL_B_RS485, name='CHANNEL_B_RS485' },
  { id=ftdi.CHANNEL_C_RS485, name='CHANNEL_C_RS485' },
  { id=ftdi.CHANNEL_D_RS485, name='CHANNEL_D_RS485' },


  -- Set all to TRISTATE.
  { id=ftdi.CBUS_FUNCTION_0, name='CBUS_FUNCTION_0' },
  { id=ftdi.CBUS_FUNCTION_1, name='CBUS_FUNCTION_1' },
  { id=ftdi.CBUS_FUNCTION_2, name='CBUS_FUNCTION_2' },
  { id=ftdi.CBUS_FUNCTION_3, name='CBUS_FUNCTION_3' },
  { id=ftdi.CBUS_FUNCTION_4, name='CBUS_FUNCTION_4' },
  { id=ftdi.CBUS_FUNCTION_5, name='CBUS_FUNCTION_5' },
  { id=ftdi.CBUS_FUNCTION_6, name='CBUS_FUNCTION_6' },
  { id=ftdi.CBUS_FUNCTION_7, name='CBUS_FUNCTION_7' },
  { id=ftdi.CBUS_FUNCTION_8, name='CBUS_FUNCTION_8' },
  { id=ftdi.CBUS_FUNCTION_9, name='CBUS_FUNCTION_9' },

  { id=ftdi.INVERT, name='INVERT' },

  -- Set channel A to UART.
  { id=ftdi.CHANNEL_A_TYPE, name='CHANNEL_A_TYPE' },
  { id=ftdi.CHANNEL_A_DRIVER, name='CHANNEL_A_DRIVER' },
  -- Set channel B to UART VCP.
  { id=ftdi.CHANNEL_B_TYPE, name='CHANNEL_B_TYPE' },
  { id=ftdi.CHANNEL_B_DRIVER, name='CHANNEL_B_DRIVER' },

  { id=ftdi.IS_NOT_PNP, name='IS_NOT_PNP' },

  { id=ftdi.SUSPEND_DBUS7, name='SUSPEND_DBUS7' },

  { id=ftdi.GROUP0_DRIVE, name='GROUP0_DRIVE' },
  { id=ftdi.GROUP0_SCHMITT, name='GROUP0_SCHMITT' },
  { id=ftdi.GROUP0_SLEW, name='GROUP0_SLEW' },
  { id=ftdi.GROUP1_DRIVE, name='GROUP1_DRIVE' },
  { id=ftdi.GROUP1_SCHMITT, name='GROUP1_SCHMITT' },
  { id=ftdi.GROUP1_SLEW, name='GROUP1_SLEW' },
  { id=ftdi.GROUP2_DRIVE, name='GROUP2_DRIVE' },
  { id=ftdi.GROUP2_SCHMITT, name='GROUP2_SCHMITT' },
  { id=ftdi.GROUP2_SLEW, name='GROUP2_SLEW' },
  { id=ftdi.GROUP3_DRIVE, name='GROUP3_DRIVE' },
  { id=ftdi.GROUP3_SCHMITT, name='GROUP3_SCHMITT' },
  { id=ftdi.GROUP3_SLEW, name='GROUP3_SLEW' },
  { id=ftdi.POWER_SAVE, name='POWER_SAVE' },
  { id=ftdi.CLOCK_POLARITY, name='CLOCK_POLARITY' },
  { id=ftdi.DATA_ORDER, name='DATA_ORDER' },
  { id=ftdi.FLOW_CONTROL, name='FLOW_CONTROL' },
  { id=ftdi.CHANNEL_C_DRIVER, name='CHANNEL_C_DRIVER' },
  { id=ftdi.CHANNEL_D_DRIVER, name='CHANNEL_D_DRIVER' },
  { id=ftdi.EXTERNAL_OSCILLATOR, name='EXTERNAL_OSCILLATOR' }
}

local astrLines = {}
table.insert(astrLines, string.format('<FtdiEeprom vendor="%s" product="%s">', strVendor, strProduct))
-- Get the EEPROM attributes.
for _, tAttr in ipairs(atValues) do
  tResult, strError = tEeprom:get_value(tAttr.id)
  assert(tResult, strError)
  local iValue = tResult
  table.insert(astrLines, string.format('\t<Set key="%s" value="%d"/>', tAttr.name, iValue))
end
table.insert(astrLines, '</FtdiEeprom>')

local strXml = table.concat(astrLines, '\n')
if tArgs.strOutputFileName==nil then
  print(strXml)
else
  local tFile = io.open(tArgs.strOutputFileName, 'w')
  tFile:write(strXml)
  tFile:close()
end

tContext:usb_close()
