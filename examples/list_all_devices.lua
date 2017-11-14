luaftdi = require 'luaftdi'

local ulUSBVendor, ulUSBProduct = 0x0403, 0xCFF8


local function print_list_entry(tListEntry)
  print('  Bus:', tListEntry:get_bus_number())
  print('  Port number:', tListEntry:get_port_number())

  print('  Port Numbers:')
  local tPN, strError = tListEntry:get_port_numbers()
  if tPN==nil then
    print('    Failed to get the port numbers:', strError)
  else
    for uiCnt, uiPort in ipairs(tPN) do
      print(string.format('    %d: 0x%02x', uiCnt, uiPort))
    end
  end

  print('  Manufacturer:', tListEntry:get_manufacturer())
  print('  Description:', tListEntry:get_description())
  print('  Serial:', tListEntry:get_serial())
end


local tVersionInfo = luaftdi.get_library_version()
print(string.format("[FTDI version] major: %d, minor: %d, micro: %d, version_str: %s, snapshot_str: %s", tVersionInfo.major, tVersionInfo.minor, tVersionInfo.micro, tVersionInfo.version_str, tVersionInfo.snapshot_str))

print("-----------------------------------------------------------------------")
print("This is an empty list entry:")
local tEmptyEntry = luaftdi.ListEntry(nil, nil)
print_list_entry(tEmptyEntry)

print("-----------------------------------------------------------------------")
print(string.format("List all devices with VID 0x%04x and PID 0x%04x.", ulUSBVendor, ulUSBProduct))

-- Create a new context.
local tContext = luaftdi.Context()

-- Scan for all devices.
local tList = tContext:usb_find_all(ulUSBVendor, ulUSBProduct)

-- Loop over all devices in the list.
for tListEntry in tList:iter() do
  print_list_entry(tListEntry)
end
