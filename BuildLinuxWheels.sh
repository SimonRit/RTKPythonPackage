#!/bin/bash
set -x
set -e
# This script should lie in a directory alongside with the RTK sources
cd RTK

# Fetch script from https://rawgit.com/InsightSoftwareConsortium/ITKPythonPackage
curl -L https://raw.githubusercontent.com/InsightSoftwareConsortium/ITKPythonPackage/master/scripts/dockcross-manylinux-download-cache-and-build-module-wheels.sh -O
chmod u+x dockcross-manylinux-download-cache-and-build-module-wheels.sh

export ITK_PACKAGE_VERSION=v5.0rc01

# Remove call to the build script to only perform the download step.
# This allows for altering the cache in case sources are not up-to-date  
replace_line="./ITKPythonPackage/scripts/dockcross-manylinux-build-module-wheels.sh"
sed -i -e "s|$replace_line||g" \
  dockcross-manylinux-download-cache-and-build-module-wheels.sh

if [[ ! -d ITKPythonPackage ]]; then
  ./dockcross-manylinux-download-cache-and-build-module-wheels.sh
fi

# Add CMake options for building the module
after_line='-DBUILD_TESTING:BOOL=OFF \\'
pwd
rtk_build_applications='-DRTK_BUILD_APPLICATIONS:BOOL=OFF \\'
sed -i -e "s|$after_line|$after_line\n      $rtk_build_applications|g" \
  ITKPythonPackage/scripts/internal/manylinux-build-module-wheels.sh

rtk_cuda='-DRTK_USE_CUDA:BOOL=OFF \\'
sed -i -e "s|$after_line|$after_line\n      $rtk_cuda|g" \
  ITKPythonPackage/scripts/internal/manylinux-build-module-wheels.sh

if [ $ITK_PACKAGE_VERSION == v4.13.0 ]; then
  echo 'Building against ITK 4.13.0 Adding -std=c++11 flag.. ' 1>&2
  cmake_cxx_flags='-DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -std=c++11" \\'
  sed -i -e "s|$after_line|$after_line\n      $cmake_cxx_flags|g" \
    ITKPythonPackage/scripts/internal/manylinux-build-module-wheels.sh
fi

# Finally build Linux wheels
./ITKPythonPackage/scripts/dockcross-manylinux-build-module-wheels.sh
