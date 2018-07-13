local t = ...
local strDistId, strDistVersion, strCpuArch = t:get_platform()
local cLog = t.cLog
local tLog = t.tLog
local tResult
local archives = require 'installer.archives'
local pl = require'pl.import_into'()


-- Copy all example files.
local atScripts = {
  ['../decode_eeprom.lua']        = '${install_base}/',
  ['../erase_eeprom.lua']         = '${install_base}/',
  ['../test_bitbang_input.lua']   = '${install_base}/',
  ['../test_bitbang_output.lua']  = '${install_base}/'
}
for strSrc, strDst in pairs(atScripts) do
  t:install(strSrc, strDst)
end

-- Install the wrapper.
if strDistId=='windows' then
  t:install('../windows/muhkuh_cli_init.lua', '${install_base}/')
elseif strDistId=='ubuntu' then
  -- This is a shell script setting the library search path for the LUA shared object.
  t:install('../linux/lua5.1.sh', '${install_base}/')
  t:install('../linux/muhkuh_cli_init.lua', '${install_base}/')
end

-- Create the package file.
local strPackageText = t:replace_template([[PACKAGE_NAME=${root_artifact_artifact}
PACKAGE_VERSION=${root_artifact_version}
PACKAGE_VCS_ID=${root_artifact_vcs_id}
HOST_DISTRIBUTION_ID=${platform_distribution_id}
HOST_DISTRIBUTION_VERSION=${platform_distribution_version}
HOST_CPU_ARCHITECTURE=${platform_cpu_architecture}
]])
local strPackageDir = t:replace_template('${install_base}/.jonchki')
local tError, strError = pl.dir.makepath(strPackageDir)
if tError~=true then
  tLog.error('Failed to create the folder "%s": %s', strPackageDir, strError)
else
  local strPackagePath = pl.path.join(strPackageDir, 'package.txt')
  local tFileError, strError = pl.utils.writefile(strPackagePath, strPackageText, false)
  if tFileError==nil then
    tLog.error('Failed to write the package file "%s": %s', strPackagePath, strError)
  else
    local Archive = archives(cLog)

    -- Create a ZIP archive for Windows platforms. Build a "tar.gz" for Linux.
    local strArchiveExtension
    local tFormat
    local atFilter
    if strDistId=='windows' then
      strArchiveExtension = 'zip'
      tFormat = Archive.archive.ARCHIVE_FORMAT_ZIP
      atFilter = {}
    else
      strArchiveExtension = 'tar.gz'
      tFormat = Archive.archive.ARCHIVE_FORMAT_TAR_GNUTAR
      atFilter = { Archive.archive.ARCHIVE_FILTER_GZIP }
    end

    local strArtifactVersion = t:replace_template('${root_artifact_artifact}-${root_artifact_version}')
    local strArchive = t:replace_template(string.format('${install_base}/../../../../repository/org/muhkuh/lua/luaftdi/${root_artifact_version}/%s-%s%s_${platform_cpu_architecture}.%s', strArtifactVersion, strDistId, strDistVersion, strArchiveExtension))
    local strDiskPath = t:replace_template('${install_base}')
    local strArchiveMemberPrefix = strArtifactVersion

    tResult = Archive:pack_archive(strArchive, tFormat, atFilter, strDiskPath, strArchiveMemberPrefix)
  end
end

return tResult
