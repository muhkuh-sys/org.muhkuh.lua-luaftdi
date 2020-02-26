local t = ...
local strDistId, strDistVersion, strCpuArch = t:get_platform()
local tResult

if strDistId=='@JONCHKI_PLATFORM_DIST_ID@' and strDistVersion=='@JONCHKI_PLATFORM_DIST_VERSION@' and strCpuArch=='@JONCHKI_PLATFORM_CPU_ARCH@' then
  t:install('lua_plugins/luaftdi.so', '${install_lua_cpath}/')
  t:install('lua/usb_tree_matcher.lua', '${install_lua_path}/')
  tResult = true
end

return tResult
