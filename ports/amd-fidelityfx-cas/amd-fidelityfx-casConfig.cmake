add_library(AMD::FidelityFX::CAS INTERFACE IMPORTED)

set_target_properties(AMD::FidelityFX::CAS PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/amd-fidelityfx-cas"
)