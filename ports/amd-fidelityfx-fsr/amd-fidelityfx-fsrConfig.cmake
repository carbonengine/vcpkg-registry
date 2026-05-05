add_library(AMD::FidelityFX::fsr INTERFACE IMPORTED)

set_target_properties(AMD::FidelityFX::fsr PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/amd-fidelityfx-fsr"
)