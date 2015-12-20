# Find/build MADNESS ===========================================================

# Check for MADNESS
if(ENABLE_MADNESS AND NOT DEV_MADNESS)
  find_package(MADNESS 0.10.1 CONFIG QUIET HINTS ${MADNESS_ROOT_DIR})
else()
  set(MADNESS_FOUND FALSE)
endif()

if(MADNESS_FOUND)

  cmake_push_check_state()
  
  list(APPEND CMAKE_REQUIRED_INCLUDES ${MADNESS_INCLUDE_DIRS} ${TiledArray_CONFIG_INCLUDE_DIRS})
  list(APPEND CMAKE_REQUIRED_LIBRARIES "${MADNESS_LINKER_FLAGS}" ${MADNESS_LIBRARIES}
      "${CMAKE_EXE_LINKER_FLAGS}" ${TiledArray_CONFIG_LIBRARIES})
  set(CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS} ${MADNESS_COMPILE_FLAGS} ${CMAKE_CXX_FLAGS}")

  # sanity check: try compiling a simple program
  CHECK_CXX_SOURCE_COMPILES(
    "
    #include <madness/world/world.h>
    int main(int argc, char** argv) {
      madness::World& world = madness::initialize(argc, argv);
      madness::finalize();
      return 0;
    }
    "  MADNESS_COMPILES)

  if (NOT MADNESS_COMPILES)
    message(FATAL_ERROR "MADNESS found, but does not compile correctly.")
  endif()
    
  if(ENABLE_ELEMENTAL)
    
    # Check to that MADNESS was compiled with Elemental support.
    CHECK_CXX_SOURCE_COMPILES(
        "
        #include <madness/world/parallel_runtime.h>
        #ifndef MADNESS_HAS_ELEMENTAL
        # error MADNESS does not have Elemental
        #endif
        int main(int, char**) { return 0; }
        "
        MADNESS_HAS_ELEMENTAL_SUPPORT
     )
        
    if(NOT MADNESS_HAS_ELEMENTAL_SUPPORT)
      message(FATAL_ERROR "MADNESS does not include Elemental support.")
    endif() 
    
    set(HAVE_ELEMENTAL ${MADNESS_HAS_ELEMENTAL_SUPPORT})
  endif()

  cmake_pop_check_state()
  
  # Add dummy target for to track dependencies between projects
  add_custom_target(madness)
  
elseif(ENABLE_MADNESS)
  

  set(MADNESS_URL "https://github.com/m-a-d-n-e-s-s/madness.git" CACHE STRING 
      "Path to the MADNESS repository")
  set(MADNESS_TAG "d2f41bde26d548c4b8b2b360b44fd6d75c61137e" CACHE STRING 
      "Revision hash or tag to use when building MADNESS")
  set(MADNESS_SOURCE_DIR "${PROJECT_BINARY_DIR}/madness/source/" CACHE PATH
      "Path to install MADNESS")
  set(MADNESS_BUILD_DIR "${PROJECT_BINARY_DIR}/madness/build/" CACHE PATH
      "Path to install MADNESS")
  set(MADNESS_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}" CACHE PATH
      "Path to install MADNESS")

  message("** Will build MADNESS from ${MADNESS_URL}")
  
  if(ELEMENTAL_FOUND)
    list(APPEND MADNESS_DEPS elemental)
  endif()

  if(MPI_FOUND)
    list(APPEND MADNESS_DEPS mpi)
  endif()

  ExternalProject_Add(madness
    DEPENDS ${MADNESS_DEPS}
    PREFIX ${MADNESS_INSTALL_PREFIX}
    STAMP_DIR ${PROJECT_BINARY_DIR}/stamp
   #--Download step--------------
    GIT_REPOSITORY ${MADNESS_URL}
    GIT_TAG ${Madness_TAG}
   #--Configure step-------------
    SOURCE_DIR ${MADNESS_SOURCE_DIR}
    CMAKE_CACHE_ARGS
        -DCMAKE_INSTALL_PREFIX:path=${MADNESS_INSTALL_PREFIX}
        -DBUILD_SHARED_LIBS:bool=${BUILD_SHARED_LIBS}
        -DCMAKE_BUILD_TYPE:string=${CMAKE_BUILD_TYPE}
        "-DCMAKE_C_COMPILER:filepath=${CMAKE_C_COMPILER}"
        "-DCMAKE_C_FLAGS:string=${CMAKE_C_FLAGS}"
        "-DCMAKE_C_FLAGS_DEBUG:string=${CMAKE_C_FLAGS_DEBUG}"
        "-DCMAKE_C_FLAGS_RELEASE:string=${CMAKE_C_FLAGS_RELEASE}"
        "-DCMAKE_C_FLAGS_RELWITHDEBINFO:string=${CMAKE_C_FLAGS_RELWITHDEBINFO}"
        "-DCMAKE_C_FLAGS_MINSIZEREL:string=${CMAKE_C_FLAGS_MINSIZEREL}"
        "-DCMAKE_CXX_COMPILER:filepath=${CMAKE_CXX_COMPILER}"
        "-DCMAKE_CXX_FLAGS:string=${CMAKE_CXX_FLAGS}"
        "-DCMAKE_CXX_FLAGS_DEBUG:string=${CMAKE_CXX_FLAGS_DEBUG}"
        "-DCMAKE_CXX_FLAGS_RELEASE:string=${CMAKE_CXX_FLAGS_RELEASE}"
        "-DCMAKE_CXX_FLAGS_RELWITHDEBINFO:string=${CMAKE_CXX_FLAGS_RELWITHDEBINFO}"
        "-DCMAKE_CXX_FLAGS_MINSIZEREL:string=${CMAKE_CXX_FLAGS_MINSIZEREL}"
        "-DCMAKE_EXE_LINKER_FLAGS:string=${DCMAKE_EXE_LINKER_FLAGS}"
# F Fortran, assume we can link without its runtime
# if you need Fortran checks enable Elemental
#        -DCMAKE_Fortran_COMPILER:filepath=${CMAKE_Fortran_COMPILER}
#        "-DCMAKE_Fortran_FLAGS:string=${CMAKE_Fortran_FLAGS}"
#        "-DCMAKE_Fortran_FLAGS_DEBUG:string=${CMAKE_Fortran_FLAGS_DEBUG}"
#        "-DCMAKE_Fortran_FLAGS_RELEASE:string=${CMAKE_Fortran_FLAGS_RELEASE}"
#        "-DCMAKE_Fortran_FLAGS_RELWITHDEBINFO:string=${CMAKE_Fortran_FLAGS_RELWITHDEBINFO}"
#        "-DCMAKE_Fortran_FLAGS_MINSIZEREL:string=${CMAKE_Fortran_FLAGS_MINSIZEREL}"
#        -DENABLE_MPI:bool=${MPI_FOUND}
        -DMPI_THREAD:string=multiple
        -DMPI_CXX_COMPILER:filepath=${MPI_CXX_COMPILER}
        -DMPI_C_COMPILER:filepath=${MPI_C_COMPILER}
#        -DENABLE_ELEMENTAL:bool=${ELEMENTAL_FOUND}
        -DLAPACK_LIBRARIES:string=${LAPACK_LIBRARIES}
        -DFORTRAN_INTEGER_SIZE:string=${FORTRAN_INTEGER_SIZE}
        -DENABLE_LIBXC:bool=ON
        -DENABLE_GPERFTOOLS:bool=OFF
#        -DASSERTION_TYPE=${MAD_EXCEPTION}
   #--Build step-----------------
    BINARY_DIR ${MADNESS_BUILD_DIR}       # Specify build dir location
   #--Install step---------------
    INSTALL_DIR ${MADNESS_INSTALL_PREFIX} # Installation prefix
    )

endif()

