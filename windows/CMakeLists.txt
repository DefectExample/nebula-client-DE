# Project-level configuration.
cmake_minimum_required(VERSION 3.14)
project(nebula_client LANGUAGES CXX)

# The name of the executable created for the application. Change this to change
# the on-disk name of your application.
set(BINARY_NAME "nebula_client")

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(VERSION 3.14...3.25)

# Define build configuration option.
get_property(IS_MULTICONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(IS_MULTICONFIG)Task: Solve MSB3073 once and for all by decoupling CMake Install from the MSBuild lifecycle.

The Problem: Even with set(CMAKE_VS_INCLUDE_INSTALL_TO_DEFAULT_BUILD OFF), the INSTALL target is failing in GitHub Actions. This is due to file(REMOVE_RECURSE) commands and permission conflicts during the final file-copying phase.

Instructions:

    In nebula_client/windows/CMakeLists.txt:

        Find the === Installation === section.

        Replace the entire installation logic from set(BUILD_BUNDLE_DIR ...) to the end of the file with the following "CI-Safe" version:
    CMake

    # === CI-Safe Installation ===
    # Disable automatic install to prevent MSB3073 in GitHub Actions
    set(CMAKE_VS_INCLUDE_INSTALL_TO_DEFAULT_BUILD OFF)

    set(BUILD_BUNDLE_DIR "$<TARGET_FILE_DIR:${BINARY_NAME}>")
    if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
      set(CMAKE_INSTALL_PREFIX "${BUILD_BUNDLE_DIR}" CACHE PATH "..." FORCE)
    endif()

    # We only keep essential INSTALL commands. 
    # REMOVED: file(REMOVE_RECURSE ...) as it causes locks in CI.
    install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}" COMPONENT Runtime)
    install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${CMAKE_INSTALL_PREFIX}/data" COMPONENT Runtime)
    install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${CMAKE_INSTALL_PREFIX}" COMPONENT Runtime)

    if(PLUGIN_BUNDLED_LIBRARIES)
      install(FILES "${PLUGIN_BUNDLED_LIBRARIES}" DESTINATION "${CMAKE_INSTALL_PREFIX}" COMPONENT Runtime)
    endif()

    # Simplified Assets Copy
    install(DIRECTORY "${PROJECT_BUILD_DIR}/flutter_assets" DESTINATION "${CMAKE_INSTALL_PREFIX}/data" COMPONENT Runtime)

    # Release AOT
    install(FILES "${AOT_LIBRARY}" DESTINATION "${CMAKE_INSTALL_PREFIX}/data" CONFIGURATIONS Profile;Release COMPONENT Runtime)

    In nebula_client/.github/workflows/build.yml:

        Let's change the Windows build command to ensure it doesn't try to trigger the install target unnecessarily:

        Change flutter build windows --release to flutter build windows --release -v. (The verbose flag helps us see if it's a specific file lock).

Execution: Apply these changes, run flutter pub upgrade nebula_core, and push.
  set(CMAKE_CONFIGURATION_TYPES "Debug;Profile;Release"
    CACHE STRING "" FORCE)
else()
  if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "Debug" CACHE
      STRING "Flutter build mode" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
      "Debug" "Profile" "Release")
  endif()
endif()
# Define settings for the Profile build mode.
set(CMAKE_EXE_LINKER_FLAGS_PROFILE "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
set(CMAKE_SHARED_LINKER_FLAGS_PROFILE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
set(CMAKE_C_FLAGS_PROFILE "${CMAKE_C_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_PROFILE "${CMAKE_CXX_FLAGS_RELEASE}")

# Use Unicode for all projects.
add_definitions(-DUNICODE -D_UNICODE)

# Compilation settings that should be applied to most targets.
#
# Be cautious about adding new options here, as plugins use this function by
# default. In most cases, you should add new options to specific targets instead
# of modifying this function.
function(APPLY_STANDARD_SETTINGS TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_17)
  target_compile_options(${TARGET} PRIVATE /W4 /WX /wd"4100")
  target_compile_options(${TARGET} PRIVATE /EHsc)
  target_compile_definitions(${TARGET} PRIVATE "_HAS_EXCEPTIONS=0")
  target_compile_definitions(${TARGET} PRIVATE "$<$<CONFIG:Debug>:_DEBUG>")
endfunction()

# Flutter library and tool build rules.
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})

# Application build; see runner/CMakeLists.txt.
add_subdirectory("runner")


# Generated plugin build rules, which manage building the plugins and adding
# them to the application.
include(flutter/generated_plugins.cmake)
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/../nebula_core/include")


# === CI-Safe Installation ===
# Disable automatic install to prevent MSB3073 in GitHub Actions
set(CMAKE_VS_INCLUDE_INSTALL_TO_DEFAULT_BUILD OFF)

set(BUILD_BUNDLE_DIR "$<TARGET_FILE_DIR:${BINARY_NAME}>")
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${BUILD_BUNDLE_DIR}" CACHE PATH "..." FORCE)
endif()

# We only keep essential INSTALL commands.
# REMOVED: file(REMOVE_RECURSE ...) as it causes locks in CI.
install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}" COMPONENT Runtime)
install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${CMAKE_INSTALL_PREFIX}/data" COMPONENT Runtime)
install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${CMAKE_INSTALL_PREFIX}" COMPONENT Runtime)

if(PLUGIN_BUNDLED_LIBRARIES)
  install(FILES "${PLUGIN_BUNDLED_LIBRARIES}" DESTINATION "${CMAKE_INSTALL_PREFIX}" COMPONENT Runtime)
endif()

# Simplified Assets Copy
install(DIRECTORY "${PROJECT_BUILD_DIR}/flutter_assets" DESTINATION "${CMAKE_INSTALL_PREFIX}/data" COMPONENT Runtime)

# Release AOT
install(FILES "${AOT_LIBRARY}" DESTINATION "${CMAKE_INSTALL_PREFIX}/data" CONFIGURATIONS Profile;Release COMPONENT Runtime)
