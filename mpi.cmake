# Find/build MPI

if(ENABLE_MPI)

  # Try to find MPI
  find_package(MPI)

endif()

if(MPI_FOUND)

  
  # Add dummy target for to track dependencies between projects
  add_custom_target(mpi)

elseif(ENABLE_MPI)

  set(MPICH_URL "http://www.mpich.org/static/downloads/3.1.4/mpich-3.1.4.tar.gz" CACHE STRING 
      "Path to the MPICH source tar ball")
  set(MPICH_DOWNDLOAD_DIR "${PROJECT_BINARY_DIR}/mpich/" CACHE PATH
      "Path to MPICH download directory")
  set(MPICH_SOURCE_DIR "${PROJECT_BINARY_DIR}/mpich/source/" CACHE PATH
      "Path to install MPICH")
  set(MPICH_BUILD_DIR "${PROJECT_BINARY_DIR}/mpich/build/" CACHE PATH
      "Path to install MPICH")
  set(MPICH_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}" CACHE PATH
      "Path to install MPICH")

  message("** Will build MPICH from ${MPICH_URL}")
  
  ExternalProject_Add(mpi
      PREFIX "${MPICH_INSTALL_PREFIX}"
      STAMP_DIR "${PROJECT_BINARY_DIR}/stamp"
     #--Download step--------------
      DOWNLOAD_DIR "${MPICH_DOWNDLOAD_DIR}"
      URL "${MPICH_URL}"
     #--Configure step-------------
      SOURCE_DIR "${MPICH_SOURCE_DIR}"
      CONFIGURE_COMMAND "${MPICH_SOURCE_DIR}/configure"
          "--prefix=${MPICH_INSTALL_PREFIX}"
          "--enable-threads=multiple"
          "--enable-cxx"
          "--disable-fortran" 
          "CC=${CMAKE_C_COMPILER}" 
          "CXX=${CMAKE_CXX_COMPILER}"
     #--Build step-----------------
      BINARY_DIR ${MPICH_BUILD_DIR}
#      BUILD_COMMAND "$(CMAKE_MAKE_PROGRAM)"
     #--Install step---------------
      INSTALL_DIR "${MPICH_INSTALL_PREFIX}"
      INSTALL_COMMAND "${CMAKE_MAKE_PROGRAM}" "install"
  )

  set(MPI_FOUND TRUE)
  set(MPI_C_COMPILER "${MPICH_INSTALL_PREFIX}/bin/mpicc")
  set(MPI_CXX_COMPILER "${MPICH_INSTALL_PREFIX}/bin/mpicxx")

endif()