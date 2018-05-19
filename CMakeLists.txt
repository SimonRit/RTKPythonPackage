project(RTKPythonPackage)

cmake_minimum_required(VERSION 2.8)

# RTK git tag
set(GIT_TAG 6becead1161dcac0f2ba59a1238168b33bb97e3f)

find_package(Git)

# Fetching RTK
execute_process(
  COMMAND ${GIT_EXECUTABLE} clone https://github.com/SimonRit/RTK.git RTK
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR})

execute_process(
  COMMAND ${GIT_EXECUTABLE} checkout ${GIT_TAG}
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/RTK)

# Copy build scripts
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/BuildLinuxWheels.sh
  ${CMAKE_BINARY_DIR}/BuildLinuxWheels.sh COPYONLY)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/BuildWindowsWheels.ps1
  ${CMAKE_BINARY_DIR}/BuildWindowsWheels.ps1 COPYONLY)
