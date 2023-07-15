local ftdi = require 'luaftdi'

local ulUSBVendor, ulUSBProduct = 0x0403, 0x6010


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
local tContext = ftdi.new()

-- Use interace "A".
local iResult = ftdi.set_interface(tContext, ftdi.INTERFACE_A)
if iResult~=0 then
  error(string.format('Failed to set the interface: %d', iResult))
end

-- Open the device.
iResult = ftdi.usb_open(tContext, ulUSBVendor, ulUSBProduct)
if iResult~=0 then
  error('Failed to open the device!')
end

-- Enable the bitbang mode and set all pins to input.
iResult = ftdi.set_bitmode(tContext, 0x00, ftdi.BITMODE_BITBANG)
if iResult~=0 then
  error(string.format('Failed to activate bitbang mode: %d', iResult))
end

-- Wait for enter.
print('Press enter to read.')
io.read()

-- Read the complete port.
local ucData
iResult, ucData = ftdi.read_pins(tContext)
if iResult<0 then
  error(string.format('Failed to read data: %d', iResult))
end
print(string.format('Port: 0x%02x', ucData))

-- Wait for enter.
print('Press enter to read again.')
io.read()


-- Read the complete port again.
iResult, ucData = ftdi.read_pins(tContext)
if iResult<0 then
  error(string.format('Failed to read data: %d', iResult))
end
print(string.format('Port: 0x%02x', ucData))

-- Wait for enter.
print('Press enter to continue.')
io.read()

ftdi.disable_bitbang(tContext)

ftdi.usb_close(tContext);
ftdi.free(tContext)
