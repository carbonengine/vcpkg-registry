# vcpkg-registry

Public vcpkg registry for carbon components and libraries.



## Pre-req for changing the registry
To use this registry with vcpkg, you can add it as a custom registry alongside the official microsoft one.

This vcpkg-registry is changed by running the update_ports.py tool.
You first need to have the microsoft vcpkg registry installed and set up on your machine.

Please follow the steps below on how to set up the necessary pre-reqs:
- Clone the microsoft/vcpkg repo if you haven't already:
  - Run: `git clone -o microsoft git@github.com:microsoft/vcpkg.git` 
- Bootstrap vcpkg.exe:
  - On Windows: `.\bootstrap-vcpkg.bat`
  - On macOS/Linux: `./bootstrap-vcpkg.sh`
- Set the VCPKG_ROOT environment variable:
  - On Windows: `setx VCPKG_ROOT "C:\path\to\vcpkg"`
    - Or add it via System Properties > Environment Variables
  - On macOS/Linux: `export VCPKG_ROOT="/path/to/vcpkg"`

## How to change the registry
- Run: `git clone -o carbonengine git@github.com:carbonengine/vcpkg-registry.git`
- Make changes to ports or add new ports as needed.
- Make sure the version of Python you are using is 3.12 or higher.
- Use the `tools/update_ports.py` script to update or add ports:
  - Run: `python tools/update_ports.py`

