add_library(AMD::FidelityFX::CACAO INTERFACE IMPORTED)

set_target_properties(AMD::FidelityFX::CACAO PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/amd-fidelityfx-cacao"
)