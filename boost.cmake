# -*- mode: cmake -*-


# Check for Boost
if(ENABLE_BOOST)
  # Limit scope of the search if BOOST_ROOT or BOOST_INCLUDEDIR is provided.
  if(BOOST_ROOT OR BOOST_INCLUDEDIR)
    set(Boost_NO_SYSTEM_PATHS TRUE)
  endif()

  find_package(Boost 1.33)

endif()

if(Boost_FOUND)

  cmake_push_check_state()

  # Perform a compile check with Boost
  list(APPEND CMAKE_REQUIRED_INCLUDES ${Boost_INCLUDE_DIR})

  CHECK_CXX_SOURCE_COMPILES(
      "
      #define BOOST_TEST_MAIN main_tester
      #include <boost/test/included/unit_test.hpp>

      BOOST_AUTO_TEST_CASE( tester )
      {
        BOOST_CHECK( true );
      }
      "  BOOST_COMPILES)
      
  cmake_pop_check_state()

  if (NOT BOOST_COMPILES)
    message(FATAL_ERROR "Boost found at ${BOOST_ROOT}, but could not compile test program")
  endif()

elseif(ENABLE_BOOST)

  # Create a cache entry for Boost build variables.
  # Note: This will not overwrite user specified values.
  set(BOOST_DOWNLOAD_DIR "${PROJECT_BINARY_DIR}/boost/" CACHE PATH 
        "Path to the Boost download directory")
  set(BOOST_SOURCE_DIR "${PROJECT_BINARY_DIR}/boost/source/" CACHE PATH 
        "Path to the Boost source directory")
  set(BOOST_BINARY_DIR "${PROJECT_BINARY_DIR}/boost/build/" CACHE PATH 
        "Path to the Boost build directory")
  set(BOOST_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})
  set(BOOST_URL "http://downloads.sourceforge.net/project/boost/boost/1.57.0/boost_1_57_0.tar.gz" CACHE STRING 
        "Path to the Boost repository")

  message("** Will build Boost from ${BOOST_URL}")

  ExternalProject_Add(boost
    PREFIX ${CMAKE_INSTALL_PREFIX}
      STAMP_DIR ${CMAKE_BINARY_DIR}/stamp
   #--Download step--------------
    URL ${BOOST_URL}
    DOWNLOAD_DIR ${BOOST_DOWNLOAD_DIR}
   #--Configure step-------------
    SOURCE_DIR ${BOOST_SOURCE_DIR}
    CONFIGURE_COMMAND ""
   #--Build step-----------------
    BUILD_COMMAND ""
   #--Install step---------------
    INSTALL_COMMAND "${CMAKE_COMMAND}" "-E" "copy_if_different" "${BOOST_SOURCE_DIR}/boost/*" "${BOOST_INSTALL_PREFIX}/include/boost/" 
   #--Custom targets-------------
    STEP_TARGETS download
    )

  set(Boost_INCLUDE_DIRS ${BOOST_INSTALL_PREFIX}/include/)
  
  # Add Boost as a dependenecy to consuming projects.
  list(APPEND TILEDARRAY_DEPENDS boost)

elseif(ENABLE_BUILD_BOOST)

endif()
