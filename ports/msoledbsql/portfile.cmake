set(DIST_URL "https://download.microsoft.com/download/A/9/8/A98CF446-A38E-4B0A-A967-F93FAB474AE0/en-US/18.1.0.0/x64/msoledbsql.msi")
set(SHA512 28cd982f892686e42b739fb9f1d5d7eef31b2faff11f010fe928298a4330e05bdadb45b48e7f02b2796ff3aca180dd63c04cfbde8e6519e1488725456dcd7841)

set(OLEDB_EXTRACT_DIR ${CURRENT_BUILDTREES_DIR}/archive)
set(OLEDB_SDK_ROOT_DIR "${OLEDB_EXTRACT_DIR}\\Program Files\\Microsoft SQL Server\\Client SDK\\OLEDB\\181\\SDK")

if (EXISTS ${OLEDB_EXTRACT_DIR})
    file(REMOVE_RECURSE ${OLEDB_EXTRACT_DIR})
endif ()

vcpkg_download_distfile(
        MSI_LOC
        URLS ${DIST_URL}
        FILENAME msoledbsql.msi
        SHA512 ${SHA512}
)

vcpkg_extract_archive(
        ARCHIVE ${MSI_LOC}
        DESTINATION ${OLEDB_EXTRACT_DIR}
)

file(COPY ${OLEDB_SDK_ROOT_DIR}/include/msoledbsql.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${OLEDB_SDK_ROOT_DIR}/lib/x64/msoledbsql.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/msoledbsqlConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/msoledbsql)
