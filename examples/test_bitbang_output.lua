local ftdi = require 'luaftdi'

-- local ulUSBVendor, ulUSBProduct = 0x1939, 0x002c
local ulUSBVendor, ulUSBProduct = 0x0403, 0x6010
-- local ulUSBVendor, ulUSBProduct = 0x0640, 0x0028


local tVersionInfo = ftdi.get_library_version()
print(string.format("[FTDI version] major: %d, minor: %d, micro: %d, version_str: %s, snapshot_str: %s", tVersionInfo.major, tVersionInfo.minor, tVersionInfo.micro, tVersionInfo.version_str, tVersionInfo.snapshot_str))

-- Create a new FTDI context.
local tContext = ftdi.new()

-- Use interace "A".
iResult = ftdi.set_interface(tContext, ftdi.INTERFACE_A)
if iResult~=0 then
  error(string.format('Failed to set the interface: %d', iResult))
end

-- Open the device.
local iResult = ftdi.usb_open(tContext, ulUSBVendor, ulUSBProduct)
if iResult~=0 then
  error('Failed to open the device!')
end

-- Enable the bitbang mode.
iResult = ftdi.set_bitmode(tContext, 0x01, ftdi.BITMODE_BITBANG)
if iResult~=0 then
  error(string.format('Failed to activate bitbang mode: %d', iResult))
end

-- Set AD0 to 0.
strData = string.char(0)
iResult = ftdi.write_data(tContext, strData)
if iResult<0 then
  error(string.format('Failed to write data: %d', iResult))
end

-- Wait for enter.
print('AD0 is now 0. Press enter.')
io.read()


-- Set AD0 to 1.
strData = string.char(1)
iResult = ftdi.write_data(tContext, strData)
if iResult<0 then
  error(string.format('Failed to write data: %d', iResult))
end

-- Wait for enter.
print('AD0 is now 1. Press enter.')
io.read()

ftdi.disable_bitbang(tContext)

ftdi.usb_close(tContext);
ftdi.free(tContext)
