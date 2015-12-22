# Find/build TBB ===============================================================

if(ENABLE_TBB)
  find_package(TBB)
endif()

if(ENABLE_TBB AND NOT TBB_FOUND)

  set(TBB_VERSION "tbb44_20151115oss")

  # Set default paths for TBB
  # This will not overwrite user defined valuse.
  set(TBB_DOWNLOAD_DIR "${PROJECT_BINARY_DIR}/tbb/" CACHE PATH 
        "Path to the TBB download directory")
  set(TBB_SOURCE_DIR "${PROJECT_BINARY_DIR}/tbb/source/" CACHE PATH
      "Path to install TBB")
  set(TBB_BUILD_DIR "${PROJECT_BINARY_DIR}/tbb/build/" CACHE PATH
      "Path to install TBB")
  set(TBB_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}" CACHE PATH
      "Path to install TBB")
  set(TBB_URL "https://www.threadingbuildingblocks.org/sites/default/files/software_releases/source/${TBB_VERSION}_src.tgz" CACHE STRING 
      "Path to the TBB repository")

  message("** Will build TBB from ${TBB_URL}")
  
  # Set the make invocation command
  if(CMAKE_GENERATOR MATCHES "Makefiles")
    set(TBB_BUILD_CMD "$(MAKE)")
  else()
    set(TBB_BUILD_CMD "${CMAKE_MAKE_PROGRAM}" "-j")
  endif()
  
  # Set the build targets
  list(APPEND TBB_BUILD_CMD "tbb" "tbbmalloc")
  
  # Set the compiler
  if(CMAKE_CXX_COMPILER_ID MATCHES "Intel" AND CMAKE_SYSTEM_NAME MATCHES "Windows")
    list(APPEND TBB_BUILD_CMD "compiler=icl")
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "Intel")
    list(APPEND TBB_BUILD_CMD "compiler=icc")
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    list(APPEND TBB_BUILD_CMD "compiler=gcc")
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    list(APPEND TBB_BUILD_CMD "compiler=clang")
  endif()

  if(CMAKE_CXX_COMPILER_ID MATCHES "Clang" AND CMAKE_SYSTEM_NAME MATCHES "Darwin")
    list(APPEND TBB_BUILD_CMD "stdlib=libc++")
  endif()
  
  list(APPEND TBB_BUILD_CMD "tbb_build_dir=${TBB_BUILD_DIR}" "tbb_build_prefix=tbb")
  
  ExternalProject_Add(tbb
      PREFIX ${TBB_INSTALL_PREFIX}
      STAMP_DIR "${PROJECT_BINARY_DIR}/stamp"
     #--Download step--------------
      DOWNLOAD_DIR "${TBB_DOWNLOAD_DIR}"
      URL "${TBB_URL}"
     #--Configure step-------------
      SOURCE_DIR "${TBB_SOURCE_DIR}"
      CONFIGURE_COMMAND ""
     #--Build step-----------------
      BINARY_DIR "${TBB_SOURCE_DIR}"
      BUILD_COMMAND ${TBB_BUILD_CMD}
     #--Install step---------------
      INSTALL_DIR "${TBB_INSTALL_PREFIX}"
      INSTALL_COMMAND "${CMAKE_COMMAND}" "-E" "make_directory" "${TBB_INSTALL_PREFIX}/lib/"
              COMMAND "${CMAKE_COMMAND}" "-E" "copy_if_different" "${TBB_BUILD_DIR}/tbb_release/${CMAKE_SHARED_LIBRARY_PREFIX}tbb${CMAKE_SHARED_LIBRARY_SUFFIX}"                   "${TBB_INSTALL_PREFIX}/lib/"
              COMMAND "${CMAKE_COMMAND}" "-E" "copy_if_different" "${TBB_BUILD_DIR}/tbb_release/${CMAKE_SHARED_LIBRARY_PREFIX}tbbmalloc${CMAKE_SHARED_LIBRARY_SUFFIX}"             "${TBB_INSTALL_PREFIX}/lib/"
              COMMAND "${CMAKE_COMMAND}" "-E" "copy_if_different" "${TBB_BUILD_DIR}/tbb_release/${CMAKE_SHARED_LIBRARY_PREFIX}tbbmalloc_proxy${CMAKE_SHARED_LIBRARY_SUFFIX}"       "${TBB_INSTALL_PREFIX}/lib/"
              COMMAND "${CMAKE_COMMAND}" "-E" "copy_if_different" "${TBB_BUILD_DIR}/tbb_debug/${CMAKE_SHARED_LIBRARY_PREFIX}tbb_debug${CMAKE_SHARED_LIBRARY_SUFFIX}"               "${TBB_INSTALL_PREFIX}/lib/"
              COMMAND "${CMAKE_COMMAND}" "-E" "copy_if_different" "${TBB_BUILD_DIR}/tbb_debug/${CMAKE_SHARED_LIBRARY_PREFIX}tbbmalloc_debug${CMAKE_SHARED_LIBRARY_SUFFIX}"         "${TBB_INSTALL_PREFIX}/lib/"
              COMMAND "${CMAKE_COMMAND}" "-E" "copy_if_different" "${TBB_BUILD_DIR}/tbb_debug/${CMAKE_SHARED_LIBRARY_PREFIX}tbbmalloc_proxy_debug${CMAKE_SHARED_LIBRARY_SUFFIX}"   "${TBB_INSTALL_PREFIX}/lib/"
              COMMAND "${CMAKE_COMMAND}" "-E" "copy_directory" "${TBB_SOURCE_DIR}/include" "${TBB_INSTALL_PREFIX}/include"
      )

  set(TBB_ROOT_DIR "${TBB_INSTALL_PREFIX}")

  # Add MPICH as a dependenecy to consuming projects.
  list(APPEND MADNESS_DEPENDS tbb)

endif()