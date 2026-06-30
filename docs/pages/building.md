## How we build Carbon Components

All of our carbon components make use of cmake, as a minimum you should have cmake installed on your machine, plus any nessecary compiler toolchains for your system.

### CMake Presets

All of our carbon components are designed to be built using predefined cmake presets specified in a [CMakePresets.json](https://github.com/carbonengine/scheduler/blob/d1fa83bac1908cab78143642a2253a832e3ccb5d/CMakePresets.json) file.

Presets just give us a convenient way of passing relevant information into the cmake configure step, including settings nessecary to run vcpkg.

This is an example of a preset:
[`arm64-osx-trinitydev` from Scheduler CMakePresets.json](https://github.com/carbonengine/scheduler/blob/d1fa83bac1908cab78143642a2253a832e3ccb5d/CMakePresets.json#L132-L139)
```
{
  "name": "arm64-osx-trinitydev",
  "inherits": "arm64-osx",
  "cacheVariables": {
    "CMAKE_BUILD_TYPE": "TrinityDev",
    "VCPKG_TARGET_TRIPLET": "arm64-osx-trinitydev",
    "VCPKG_HOST_TRIPLET": "arm64-osx-trinitydev"
  }
},
```

A build using a preset preset can be invoked like so:
`cmake --preset arm64-osx-trinitydev`
Given you have correctly installed a support version of cmake the relavent compiler toolchains on your system, simply running this line is enough to build any carbon component.
You must use the correct preset for your system. You can list presets relavent to your system with the command:
`cmake --list-presets`
```
> cmake --list-presets
Available configure presets:
  "x64-windows-internal"
  "x64-windows-release"
  "x64-windows-debug"
  "x64-windows-trinitydev"
```

#### Customising Presets Locally
It is often nessecary to change presets for local use. You can do this by creating a CMakeUserPresets file, and extending preset you wish to adjust:
`CMakeUserPresets.json`
```
{
  "version": 3,
  "cmakeMinimumRequired": {
    "major": 3,
    "minor": 31,
    "patch": 0
  },
  "configurePresets": [
    {
      "inherits": ["x64-windows-debug"],
      "name": "localdebug",
      "environment": {
      },
      "cacheVariables": {
        "VCPKG_INSTALL_OPTIONS": "--x-buildtrees-root=C:/buildtrees"
      },
    }
  ]
}
```
Here we create a `localdebug` preset, that inherits it's settings from the `x64-windows-debug` preset in the main presets file. Any configuration given here will override anything provided in the preset you inherit from.

This particular customization is useful on windows:
```
"cacheVariables": {
	"VCPKG_INSTALL_OPTIONS": "--x-buildtrees-root=C:/buildtrees"
},
```
As the limited path length on windows can cause the vcpkg build to break, setting `--x-buildtrees-root` to the root directory mitigates this problem.

### Toolchain Files

vcpkg controls the build environment for a project's dependencies, not for that project it'self.
For example, I have a C++ project:
```
CMakeLists.txt
src/
	main.cpp
CMakePresets.json
vcpkg.json
vcpkg-configuration.json
vendor/
	carbonengine/vcpkg-regitry/
	microsoft/vcpkg/
```

As mentioned in the [vcpkg primer](vcpkg-primer.md), triplet files control the build environment, compiler & linker flags for dependencies. It is a mistake to assume that they do this for your "top-level project".

In this example project, build and linker flags for `main.cpp` is entirely the responsibility of the `CMakeLists.txt` and any configuration passed to it from cmake.

However, as most carbon components share a common set of build and linker flags, it is useful to be able to share configuration between vcpkg dependency builds, and top level cmake builds. This is where our toolchain files come in.

Toolchain files are read by cmake on configuration start, before cmake has started to process for `CMakeLists.txt` file. They are used to provide information on your compiler toolchain, build and linker flags. However vcpkg demands that you use it's [`vcpkg.cmake`](https://github.com/microsoft/vcpkg/blob/a0400024711b283056538ac19ced80b91a83c24c/scripts/buildsystems/vcpkg.cmake) file as cmake's toolchain file when building through cmake. How do we provide our own toolchain file? vcpkg has a mechanism to allow this using the cmake variable: `VCPKG_CHAINLOAD_TOOLCHAIN_FILE`.
We set that cmake cache variable to the path to the relevant toolchain file in the `carbonengine/vcpkg-registry` submodule in each carbon component's repository.
All of our toolchain files are contained in the [toolchains/](../toolchains) directory:

[toolchains/](../toolchains)
```
x64-windows-carbon.cmake
arm64-osx-carbon.cmake
x64-osx-carbon.cmake

arm64-osx-triplet.cmake
x64-windows-triplet.cmake
x64-osx-triplet.cmake
```

[`CMakePresets.json`](https://github.com/carbonengine/scheduler/blob/d1fa83bac1908cab78143642a2253a832e3ccb5d/CMakePresets.json#L42-L49)
```
{
  "name": "x64-windows",
  "inherits": "windows",
  "cacheVariables": {
    "VCPKG_CHAINLOAD_TOOLCHAIN_FILE": "${sourceDir}/vendor/github.com/carbonengine/vcpkg-registry/toolchains/x64-windows-carbon.cmake"
  },
  "hidden": true
},
```

Here is that [toolchain file](https://github.com/carbonengine/vcpkg-registry/blob/a8c2830118190bc9aad76fde07d99279c3311ee2/toolchains/x64-windows-carbon.cmake)
is contains things like this:
```
...
set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreadedDLL CACHE STRING INTERNAL FORCE)
set(CMAKE_SYSTEM_VERSION 10.0.17763.0 CACHE STRING INTERNAL FORCE)
set(CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION 10.0.17763.0 CACHE STRING INTERNAL FORCE)

# Windows 10 is our minimum requirement, so make sure we're enforcing it.
add_compile_definitions(WINVER=0x0A00)
add_compile_definitions(_WIN32_WINNT=0x0A00)
add_compile_definitions(_WIN32_WINDOWS=0x0A00)
add_compile_definitions(NTDDI_VERSION=0x0A000000)
...
```

We also want to make use of this configuration file, when building carbon components as dependencies through vcpkg. For instance, when we are building [carbon-io](https://github.com/carbonengine/io/), we want to use the same toolchain file to build [carbon-scheduler](https://github.com/carbonengine/scheduler/), which it depends on.

The `VCPKG_CHAINLOAD_TOOLCHAIN_FILE` option only applies the toolchain file to your TOP LEVEL PROJECT, NOT any vcpkg dependency builds. In order to apply a toolchain file to a vcpkg dependency build, you must set the `VCPKG_CHAINLOAD_TOOLCHAIN_FILE` cache variable inside a triplet file:

[`x64-windows-release.cmake`](https://github.com/carbonengine/vcpkg-registry/blob/a8c2830118190bc9aad76fde07d99279c3311ee2/triplets/x64-windows-release.cmake#L20-L23)
```
if (PORT MATCHES "carbon-.*")
    set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/../toolchains/x64-windows-triplet.cmake")
    set(VCPKG_HASH_ADDITIONAL_FILES "${CMAKE_CURRENT_LIST_DIR}/../toolchains/x64-windows-carbon.cmake")
endif ()
```

We only want the toolchain file to apply to builds of carbon components, nothing else (EG we don't want to build curl or libpng with our toolchain file), which is why we guard it with an `if (PORT MATCHES "carbon-.*")` [per port customization](https://learn.microsoft.com/en-us/vcpkg/users/triplets#per-port-customization)

Notice that we set `VCPKG_CHAINLOAD_TOOLCHAIN_FILE` to `x64-windows-triplet.cmake`, not `x64-windows-carbon.cmake` as we do in our `CMakePresets.json` file. This is because there's a requirement that when setting a chainloaded toolchain file for a vcpkg dependency, that toolchain file must include vcpkg's system specific toolchain file:

[`x64-windows-triplet.cmake`](https://github.com/carbonengine/vcpkg-registry/blob/a8c2830118190bc9aad76fde07d99279c3311ee2/toolchains/x64-windows-triplet.cmake)
```
# Copyright © 2025 CCP ehf.
# This toolchain is meant for use inside a vcpkg triplet. See `README.md` for more details.
include($ENV{PATH_TO_VCPKG_ROOT}/scripts/toolchains/windows.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../toolchains/x64-windows-carbon.cmake)
```
In the chainloaded windows toolchain file meant for our vcpkg dependencies, we first include vcpkg's `windows.cmake` file, then our shared `x64-windows-carbon.cmake` toolchain file. 

Notice in the triplet excerpt above, the line: `set(VCPKG_HASH_ADDITIONAL_FILES "${CMAKE_CURRENT_LIST_DIR}/../toolchains/x64-windows-carbon.cmake")`
This is nesecary, because we want vcpkg to consider `x64-windows-carbon.cmake` to be part of how it tracks ABI compatability. Without this line, it doesn't know to do this.