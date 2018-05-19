trap { Write-Error $_; Exit 1 }

# WebRequest protocol
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# This script should lie in a directory alongside with the RTK sources
cd RTK

# Fetch script from https://rawgit.com/InsightSoftwareConsortium/ITKPythonPackage
curl https://rawgit.com/InsightSoftwareConsortium/ITKPythonPackage/master/scripts/windows-download-cache-and-build-module-wheels.ps1 -OutFile windows-download-cache-and-build-module-wheels.ps1

# Remove call to the build script to only perform the download step.
# This allows for altering the cache in case sources are not up-to-date
$file='.\windows-download-cache-and-build-module-wheels.ps1'
$remove_line='C:\Python35-x64\python.exe C:\P\IPP\scripts\windows_build_module_wheels.py'
(Get-Content $file).replace($remove_line, '') | Set-Content $file

# Specify python version to install using install_python.ps1
$after_line='iex ((new-object net.webclient).DownloadString(''https://raw.githubusercontent.com/scikit-build/scikit-ci-addons/master/windows/install-python.ps1''))'
$command='Invoke-WebRequest -Uri "https://raw.githubusercontent.com/scikit-build/scikit-ci-addons/master/windows/install-python.ps1" -OutFile "install-python.ps1"
& { $pythonVersion = "3.6"; $pythonArch = "64"; .\install-python.ps1 }'
(Get-Content $file).replace($after_line, $command) | Set-Content $file

# Download cache
if(!(Test-Path -Path 'C:\P\IPP\scripts')){
  .\windows-download-cache-and-build-module-wheels.ps1
}

# Specify python version to build wheels
$file='C:\P\IPP\scripts\internal\windows_build_common.py'
$replace_line='DEFAULT_PY_ENVS = ["35-x64", "36-x64"]'
$command='DEFAULT_PY_ENVS = ["36-x64"]'
(Get-Content $file).replace($replace_line, $command) | Set-Content $file

$replace_line='        ROOT_DIR, "venv-35-x64", "Scripts", "ninja.exe")'
$command='        ROOT_DIR, "venv-36-x64", "Scripts", "ninja.exe")'
(Get-Content $file).replace($replace_line, $command) | Set-Content $file

# Apply patch from https://github.com/InsightSoftwareConsortium/ITK/commit/83801da92519a49934b265801d303a6531856b50
$after_line='set(image "${ITKN_${name}}")'
$command='set(image "${ITKN_${name}}") 
    if(image STREQUAL "")
      string(REPLACE "I" "itkImage" imageTemplate ${name})
      set(image ${imageTemplate})
    endif()'
$file='C:\P\IPP\standalone-build\ITK-source\Wrapping\Generators\Python\CMakeLists.txt'
(Get-Content $file).replace($after_line, $command) | Set-Content $file

# Add CMake options
$after_line='"-DBUILD_TESTING:BOOL=OFF",'
$command='"-DBUILD_TESTING:BOOL=OFF", 
                "-DRTK_BUILD_APPLICATIONS:BOOL=OFF",'
$file='C:\P\IPP\scripts\windows_build_module_wheels.py'
(Get-Content $file).replace($after_line, $command) | Set-Content $file

$remove_line='"-DITK_WRAP_unsigned_short:BOOL=ON",'
$file='C:\P\IPP\scripts\windows_build_module_wheels.py'
(Get-Content $file).replace($remove_line, '') | Set-Content $file

# Finally build Windows wheels
C:\Python36-x64\python.exe C:\P\IPP\scripts\windows_build_module_wheels.py
