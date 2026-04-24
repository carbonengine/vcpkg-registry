add_library(AMD::FidelityFX::FSR INTERFACE IMPORTED)

set_target_properties(AMD::FidelityFX::FSR PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/amd-fidelityfx-fsr"
)