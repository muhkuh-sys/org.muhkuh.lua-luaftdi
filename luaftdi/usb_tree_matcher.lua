------------
-- Look for a combination of devices based on their USB location.
-- @module UsbTreeMatcher
-- @author Christoph Thelen
-- @license GPL-v2
-- @copyright 

local class = require 'pl.class'
local UsbTreeMatcher = class()


function UsbTreeMatcher:_init(tLog)
  self.tLog = tLog

  local luaftdi = require 'luaftdi'
  self.luaftdi = luaftdi

  -- Get the list of all connected USB devices.
  self:__rescan()
end



function UsbTreeMatcher:__rescan()
  local tLog = self.tLog
  local atDetectedDevices

  -- Create a new FTDI context and get all USB devices.
  tLog.debug('Get a list of all USB devices.')
  local tContext = luaftdi.Context()
  local tDeviceList = tContext:usb_get_all()
  if tDeviceList==nil then
    tContext:close()
    tContext = nil
    tLog.error('Failed to get all USB devices.')
  else
    atDetectedDevices = {}
    for tListEntry in tDeviceList:iter() do
      local usVID = tListEntry:get_vid()
      local usPID = tListEntry:get_pid()
      local strVidPid = string.format('%04x:%04x', usVID, usPID)

      local tPorts = tListEntry:get_port_numbers()
      -- Skip root devices (which have no ports).
      if #tPorts~=0 then
        -- Convert all elements to integer (important for lua5.4).
        for uiCnt, ucPort in ipairs(tPorts) do
          tPorts[uiCnt] = math.floor(ucPort)
        end
        local ucBus = tListEntry:get_bus_number()
        local strLocation = string.format('%d:%s', ucBus, table.concat(tPorts, ','))
        atDetectedDevices[strLocation] = {
          vid = usVID,
          pid = usPID,
          vidpid = strVidPid,
          bus = ucBus,
          address = tListEntry:get_device_address(),
          ports = tPorts,
          location = strLocation,
          context = tContext,
          device = tListEntry
        }
      end
    end
  end
  self.tDeviceList = atDetectedDevices
end



---- Search for a set of USB devices.
-- @param atDevices
-- @param[opt] fForceRescan
function UsbTreeMatcher:search(atDevices, fForceRescan)
  local tLog = self.tLog
  local atDeviceLookup = {}

  -- Use the default of "false" for fForceRescan.
  if fForceRescan==nil then
    fForceRescan = false
  end

  -- Is a rescan needed?
  local fDoRescan = false
  if fForceRescan==true then
    tLog.debug('Re-scan was forced.')
    fDoRescan = true
  elseif self.tDeviceList==nil then
    tLog.debug('Re-scan because no device list is available yet.')
    fDoRescan = true
  else
    tLog.debug('No re-scan needed. Using existing device list.')
  end
  if fDoRescan==true then
    self:__rescan()
    tDeviceList = self.tDeviceList
  end

  local tDeviceList = self.tDeviceList
  if tDeviceList~=nil then
    -- Dump all detected devices.
    tLog.debug('All detected USB devices:')
    for strPath, tDevice in pairs(tDeviceList) do
      tLog.debug('    %s : %s', strPath, tDevice.vidpid)
    end

    -- Loop over all detected devices.
    local strMatchingPrefix = nil
    for strPath, tDetectedDevice in pairs(tDeviceList) do
      -- Does the device match one of the expected devices?
      for strDeviceName, v in pairs(atDevices) do
        strExpectedVidPid = v[1]
        strExpectedPath = v[2]
        if tDetectedDevice.vidpid==strExpectedVidPid then
          local strPrefix = nil
          -- Does the last part of the path match?
          if strPath==strExpectedPath then
            -- The path matches without prefix.
            strPrefix = ''
          elseif string.sub(strPath, -(1+string.len(strExpectedPath)))==(':'..strExpectedPath) then
            -- The path matches all ports starting at the root device.
            strPrefix = string.sub(strPath, 1, string.len(strPath)-string.len(strExpectedPath))
          elseif string.sub(strPath, -(1+string.len(strExpectedPath)))==(','..strExpectedPath) then
            -- The path matches some of the ports.
            strPrefix = string.sub(strPath, 1, string.len(strPath)-string.len(strExpectedPath))
          end

          if strPrefix~=nil then
            -- Now look for all expected devices with this prefix.
            local fOk = true
            for uiTestMatrixDeviceNumber, v in pairs(atDevices) do
              strPathEnd = v[2]
              strVidPid = v[1]
              local strPath = strPrefix .. strPathEnd
              local tDevice = tDeviceList[strPath]
              if tDevice==nil then
                fOk = false
                break
              elseif tDevice.vidpid~=strVidPid then
                fOk = false
                break
              end
            end

            if fOk==true then
              strMatchingPrefix = strPrefix
              break
            end
          end
        end
      end
    end

    if strMatchingPrefix==nil then
      tLog.debug('No match found.')
    else
      tLog.debug('Found a match at prefix %s .', strMatchingPrefix)
      -- Build a lookup table.
      for _, v in pairs(atDevices) do
        local strPathEnd = v[2]
        local strLocation = strMatchingPrefix .. strPathEnd
        local strDeviceId = v[3]
        atDeviceLookup[strDeviceId] = tDeviceList[strLocation]
      end

      tLog.debug('Matching device set:')
      for strDeviceId, tDevice in pairs(atDeviceLookup) do
        tLog.debug('  %s (%s) at %s', strDeviceId, tDevice.vidpid, tDevice.location)
      end
    end
  end

  return atDeviceLookup
end


return UsbTreeMatcher

