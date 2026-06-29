# VCPKG Primer

This primer is a useful starting point for learning about VCPKG and how we use it to build the Carbon Engine. It provides information & context where I felt the official vcpkg documentation was unclear or simply lacking.
[**The official vcpkg documentation website**](https://learn.microsoft.com/en-us/vcpkg/) provides an excellent reference for everything discussed here, and if you want to learn more about how VCPKG works, you should go and read that.

If you are an employee of Fenris Creations and want a more thourough understanding of how we leverage VCPKG in our builds, please see the video of my (ccptoebeans) VCPKG Training Session that I ran for the platform team before we carried out the open source project.
This documentation is a distillation of the information given in that training session.

### Does it do?

VCPKG is a tool for managing dependencies of C/C++ projects.
It performs multiple jobs:
- Tracking dependencies & their versions in [Registries](https://learn.microsoft.com/en-us/vcpkg/concepts/registries)
- Building dependencies across different target platforms & architectures with [Triplet files](https://learn.microsoft.com/en-us/vcpkg/concepts/triplets)
- Providing a clean reproduceable build environment for dependency builds, such that builds can be guarenteed to be the same across different host machines, given they use the same triplet file.

Specifically, it allows us to encode knowledge of a project's dependencies & their versions into json files that can be tracked in source control with each component:
scheduler's dependencies:
[vcpkg.json](https://github.com/carbonengine/scheduler/blob/d1fa83bac1908cab78143642a2253a832e3ccb5d/vcpkg.json)
```
{
  "dependencies": [
    {
      "name": "python3",
      "version>=": "3.12.9#1"
    },
    {
      "name": "greenlet",
      "version>=": "3.0.3#1"
    },
    {
      "name": "carbon-core",
      "version>=": "2.4.0"
    },
    {
      "name": "gtest",
      "version>=": "1.16.0"
    }
  ]
}
```

Each component can itself be provided as a package, or "port" consumable through VCPKG.
scheduler's vcpkg port is [here](https://github.com/carbonengine/vcpkg-registry/tree/fcc57c09e7a86b45da0570947e8294c401a403ae/ports/carbon-scheduler)
A port contains a `vcpkg.json` file specifying the port's version and listing it's dependencies, and a `portfile.cmake` script, responsible for building the package.

carbon-scheduler's `portfile.cmake` script
[portfile.cmake](https://github.com/carbonengine/vcpkg-registry/blob/fcc57c09e7a86b45da0570947e8294c401a403ae/ports/carbon-scheduler/portfile.cmake)
```
vcpkg_from_git(
  OUT_SOURCE_PATH SOURCE_PATH
  URL git@github.com:carbonengine/scheduler.git
  REF 327303b539aaf1850ebcc4ad73460e3a61855cff
  HEAD_REF main
)

vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS
    -DBUILD_TESTING=OFF
    -DBUILD_DOCUMENTATION=OFF
    -DCMAKE_BUILD_TYPE=${CARBON_BUILD_TYPE}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()
set(BUILD_PATHS
  "${CURRENT_PACKAGES_DIR}/bin/*.dll"
  "${CURRENT_PACKAGES_DIR}/debug/bin/*.dll"
  "${CURRENT_PACKAGES_DIR}/bin/*.pyd"
  "${CURRENT_PACKAGES_DIR}/debug/bin/*.pyd"
)
vcpkg_copy_pdbs(
  BUILD_PATHS ${BUILD_PATHS}
)
ccp_externalize_apple_debuginfo()
```


### How does it work?

We use VCPKG through CMake. As soon a the CMake configure step begins, it runs the [vcpkg.cmake](https://github.com/microsoft/vcpkg/blob/a0400024711b283056538ac19ced80b91a83c24c/scripts/buildsystems/vcpkg.cmake) toolchain file, which calls the vcpkg executable, which then reads the vcpkg.json & vcpkg-configuration.json files. From these two files, it builds a dependency tree with the correct versions of each package, downloads & builds those packages. Each dependency package gets built by running each one's [portfile.cmake](../ports/carbon-core/portfile.cmake) cmake script.

To allow this to happen with minimal end-user configuration, we submodule the [microsoft/vcpkg](https://github.com/microsoft/vcpkg) repository into all of our engine component's git repositories under [vendor/github.com/microsoft/vcpkg](https://github.com/carbonengine/core/tree/main/vendor/github.com/microsoft)
As this repository [carbonengine/vcpkg-registry](https://github.com/carbonengine/vcpkg-registry) contains important configuration shared between all components, we also submodule this in to our carbon component repositories under [vendor/github.com/carbonengine/vcpkg-registry](https://github.com/carbonengine/core/tree/main/vendor/github.com/carbonengine)

### How VCPKG Resolves Dependencies

As I mentioned above, a VCPKG port contains two files, a vcpkg.json file and a portfile.
the vcpkg.json file contains version information about the package:
[ports/carbon-scheduler/vcpkg.json](https://github.com/carbonengine/vcpkg-registry/blob/fcc57c09e7a86b45da0570947e8294c401a403ae/ports/carbon-scheduler/vcpkg.json)
```
"name": "carbon-scheduler",
"version": "1.4.2",
"description": "Provides channels and a scheduler for Greenlet coroutines.",
"homepage": "https://github.com/carbonengine/scheduler",
```
You can see here that this port is at version 1.4.2 of scheduler.
The portfile is responsible for downloading scheduler at that version:
[ports/carbon-scheduler/portfile.cmake](https://github.com/carbonengine/vcpkg-registry/blob/fcc57c09e7a86b45da0570947e8294c401a403ae/ports/carbon-scheduler/portfile.cmake)
```
vcpkg_from_git(
  OUT_SOURCE_PATH SOURCE_PATH
  URL git@github.com:carbonengine/scheduler.git
  REF 327303b539aaf1850ebcc4ad73460e3a61855cff
  HEAD_REF main
)
```
the `REF` here is set to the git commit `327303b539aaf1850ebcc4ad73460e3a61855cff`, which in the scheduler repository, is tagged as [v1.4.2](https://github.com/carbonengine/scheduler/tree/v1.4.2).

This is plain enough. But how does vcpkg allow us to access earlier versions of scheduler?
Consider the case of a component relying on `v1.4.1` of scheduler:
```
{
    "name": "carbon-scheduler",
    "version>=": "1.4.1"
}
```
Firstly, VCPKG will always use the **MINIMUM** version of any dependency. This is why version numbers are always specified as minimums (` version >= ~ `). If anything else in our build tree also depends on scheduler, it will choose the lowest version it can that satisfies all version constraints.
For instance, if we depend on scheduler at >=1.4.1, but one of our dependencies depends on scheduler at >=1.4.0. VCPKG will choose 1.4.1, as this satisfies both version constraints.

VCPKG will then access your [vcpkg-configuration.json](https://github.com/carbonengine/io/blob/5c4c669f6ebbda56996f1326315222dae9bf281e/vcpkg-configuration.json#L12) file to determine which VCPKG registry contains the carbon-scheduler port, it will then download that registry.
It will then inspect the [relevant version file for carbon-scheduler](https://github.com/carbonengine/vcpkg-registry/blob/fcc57c09e7a86b45da0570947e8294c401a403ae/versions/c-/carbon-scheduler.json)
```
{
  "versions": [
    {
      "git-tree": "c726a8e9b2ba9d21da3eb56ccb21e341f27b6c90",
      "version": "1.4.2",
      "port-version": 0
    },
    {
      "git-tree": "fd1982af1a2699de5406f133cbc951975c69d952",
      "version": "1.4.1",
      "port-version": 0
    },
    {
      "git-tree": "0bcb6b83d3259760273ee5f9fdd37f1c3427634a",
      "version": "1.4.0",
      "port-version": 0
    }
  ]
}
```
Here we can see that our registry contains 3 different versions of scheduler, `1.4.2`, `1.4.1` and `1.4.0`. We're looking for `1.4.1`. 
Notice the `git-tree` field in each version object. This hash `fd1982af1a2699de5406f133cbc951975c69d952` is the git-object-hash of scheduler's port directory, at the commit that `1.4.1` was added to the repository. [Here](https://github.com/carbonengine/vcpkg-registry/tree/7d42c331ccbeb413db97ead9e8cde2b85931e820/ports/carbon-scheduler).
Using that hash, it is able to access that directory at that specific commit. It then reads the vcpkg.json file, does the same thing for all of **it's** dependencies, and then proceeds to run the `portfile.cmake` script, which builds scheduler for us.

This leads nicely into my next point, which is that the only directories important for a vcpkg registry, are the `ports/` directory and the `versions/` directory. The `ports/` directory is maintained by hand, and the `versions/` directory is maintained by tooling. 
***Please do not manually edit the contents of the `versions/` directory unless you know what you are doing.***
There might be scenario's where editing the versions directory is nessecary, but they are rather specific, and something else has ususally already gone wrong.

### Controling the Build Environment

Build & linker flags, compiler information, target & host platform information are all provided through what are called "triplet" files. These are cmake scripts that are able to set a selection VCPKG CMake variables ([documented here](https://learn.microsoft.com/en-us/vcpkg/users/triplets)) that control how dependencies are built.
One triplet file represents a target Platform, architecture & build flavour. EG [Windows x64 Release](https://github.com/microsoft/vcpkg/blob/master/triplets/x64-windows-release.cmake)
VCPGK comes with a set of [default triplet files](https://github.com/microsoft/vcpkg/tree/master/triplets) that it is able to use out of the box. But you are able to define your own, as we do.
This repository defines a set of triplet files one for each Platform Architecture and build flavour combination, that must be used to build components of the carbon game-engine.

Our triplet files:
```
arm64-osx-debug
arm64-osx-internal
arm64-osx-release
arm64-osx-trinitydev
x64-osx-debug
x64-osx-internal
x64-osx-release
x64-osx-trinitydev
x64-windows-debug
x64-windows-internal
x64-windows-release
x64-windows-trinitydev
```

Using our own triplet files allow us to customize specific things in about build to suit our needs. For instance:
- Specify the verion of the MSVC toolchain we are using on windows
    ```
    set(VCPKG_PLATFORM_TOOLSET v141)
    ```
- Set all of our build and linker flags from our standard platform-specific toolchain file:
    ```
    if (PORT MATCHES "carbon-.*")
        set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/../toolchains/x64-windows-triplet.cmake")
        set(VCPKG_HASH_ADDITIONAL_FILES "${CMAKE_CURRENT_LIST_DIR}/../toolchains/x64-windows-carbon.cmake")
    endif ()
    ```
- Provide customizations for certain dependencies where we need them, for example:
    - We build libvorbis statically
        ```
        if (PORT MATCHES "libvorbis")
            set(VCPKG_LIBRARY_LINKAGE static)
        endif ()
        ```
    - We increase the minimum version of cmake that civetweb is able to use:
        ```
        if (PORT MATCHES "civetweb")
            set(VCPKG_CMAKE_CONFIGURE_OPTIONS "-DCMAKE_POLICY_VERSION_MINIMUM=3.5")
        endif ()
        ```
