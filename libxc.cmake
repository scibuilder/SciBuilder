# Find/build Libxc

if(ENABLE_LIBXC)
  find_package(Libxc)
endif()

if(NOT LIBXC_FOUND AND ENABLE_LIBXC)
  
  # Set default paths for libxc
  # This will not overwrite user defined valuse.
  set(LIBXC_DOWNLOAD_DIR "${PROJECT_BINARY_DIR}/libxc/" CACHE PATH 
        "Path to the libxc download directory")
  set(LIBXC_SOURCE_DIR "${PROJECT_BINARY_DIR}/libxc/source/" CACHE PATH
      "Path to install libxc")
  set(LIBXC_BUILD_DIR "${PROJECT_BINARY_DIR}/libxc/build/" CACHE PATH
      "Path to install libxc")
  set(LIBXC_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}" CACHE PATH
      "Path to install libxc")
  set(LIBXC_URL "http://www.tddft.org/programs/octopus/down.php?file=libxc/libxc-2.2.2.tar.gz" CACHE STRING 
      "Path to the libxc repository")

  message("** Will build libxc from ${LIBXC_URL}")

  ExternalProject_Add(libxc
      PREFIX "${LIBXC_INSTALL_PREFIX}"
      STAMP_DIR "${PROJECT_BINARY_DIR}/stamp"
     #--Download step--------------
      DOWNLOAD_DIR "${LIBXC_DOWNLOAD_DIR}"
      URL "${LIBXC_URL}"
     #--Configure step-------------
      SOURCE_DIR "${LIBXC_SOURCE_DIR}"
      CONFIGURE_COMMAND "${LIBXC_SOURCE_DIR}/configure"
          "--prefix=${LIBXC_INSTALL_PREFIX}"
          "--disable-fortran"
          "${ENABLE_SHARED}" 
          "${ENABLE_STATIC}"
          "CC=${CMAKE_C_COMPILER}" 
          "CFLAGS=${CFLAGS}"
          "LDFLAGS=${LDFLAGS}"
     #--Build step-----------------
      BINARY_DIR "${LIBXC_BUILD_DIR}"
     #--Install step---------------
      INSTALL_DIR "${LIBXC_INSTALL_PREFIX}"
  )

  set(LIBXC_ROOT_DIR "${LIBXC_INSTALL_PREFIX}")

  # Add MPICH as a dependenecy to consuming projects.
  list(APPEND MADNESS_DEPENDS libxc)

endif()