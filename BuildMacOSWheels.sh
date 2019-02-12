#!/bin/bash

export ITK_PACKAGE_VERSION=v5.0rc01

# Fetch script from https://rawgit.com/InsightSoftwareConsortium/ITKPythonPackage
if ! test -e /Users/kitware/Dashboards/ITK
then
    mkdir -p  /Users/kitware/Dashboards/ITK
    cd  /Users/kitware/Dashboards/ITK
    curl -L https://raw.githubusercontent.com/InsightSoftwareConsortium/ITKPythonPackage/master/scripts/macpython-download-cache-and-build-module-wheels.sh -O
    chmod u+x macpython-download-cache-and-build-module-wheels.sh
    sed -i "" -e "s|\(.*\){ITK_PACKAGE_VERSION:=v5.0b01}\(.*\)|\1{ITK_PACKAGE_VERSION:=${ITK_PACKAGE_VERSION}}\2|g" \
      macpython-download-cache-and-build-module-wheels.sh
    sed -i "" -e "s|.*macpython-build-module-wheels.sh .*||g" \
      macpython-download-cache-and-build-module-wheels.sh
    ./macpython-download-cache-and-build-module-wheels.sh

    for i in /Users/kitware/Dashboards/ITK/ITKPythonPackage/venvs/*/bin/python
    do
        $i -m pip install scikit-build
    done
fi

#sed -i "" "s/\/Users\/Kitware\/Dashboards\/ITK/$(pwd | sed "s/\//\\\\\//g")/g" macpython-download-cache-and-build-module-wheels.sh

# This script should lie in a directory alongside with the RTK sources
cd /Users/kitware/Dashboards
if ! test -e RTK
then
  git clone https://github.com/SimonRit/RTK.git
fi
cd RTK

# Add CMake options for building the module
after_line='-DBUILD_TESTING:BOOL=OFF'

rtk_build_applications='-DRTK_BUILD_APPLICATIONS:BOOL=OFF \\'
sed -i -e "s|$after_line.*$|$after_line $rtk_build_applications|g" \
  /Users/kitware/Dashboards/ITK/ITKPythonPackage/scripts/macpython-build-module-wheels.sh

# Finally build Linux wheels
/Users/kitware/Dashboards/ITK/ITKPythonPackage/scripts/macpython-build-module-wheels.sh
