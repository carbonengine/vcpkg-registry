# vcpkg-registry

CCP Games' public vcpkg registry for developing its [Carbon engine](https://www.ccpgames.com/carbon)

This registry is intended to be used in addition to the [official Microsoft vcpkg registry](https://github.com/microsoft/vcpkg).

## Contributing to this registry
- Place your contributions in a branch
- Either follow the [Steps 3 and 4 as mentioned in the documentation](https://learn.microsoft.com/en-us/vcpkg/produce/publish-to-a-git-registry)
- Or use the provided `update_ports.py` utility to achieve the same result, e.g.: `python tools/update_ports.py`.
  - The utility expects that `VCPKG_ROOT` [has been set up correctly](https://learn.microsoft.com/en-us/vcpkg/get_started/get-started-packaging?pivots=shell-bash#2---configure-the-vcpkg_root-environment-variable).
- Open a PR from your branch onto main.

