#!/usr/bin/env python
"""
Utility script to test that all ports in the registry can be installed successfully, heavily inspired by
[the documentation on testing registry ports](https://learn.microsoft.com/en-us/vcpkg/produce/test-registry-ports-gha).

Copyright © 2026 CCP ehf.
"""
import argparse
import json
import os
import subprocess
import tempfile
import unittest
from unittest.mock import mock_open, patch


# The `Configuration` class keeps track of relevant application wide state.
class Configuration:
    __slots__ = ('BASELINE_JSON_PATH', 'VCPKG_ENV', 'REGISTRY_PATH', 'GENERATED_MANIFEST_PATH', 'VCPKG_CLONE_PATH', 'IGNORED_PACKAGES')

    def __init__(self, options: argparse.Namespace):
        # Assume that, by default, the CI script gets run from inside the registry. Can be overridden with the `--registry-root`
        # switch.
        self.REGISTRY_PATH = os.path.normpath(os.path.join(os.path.dirname(__file__), ".."))
        self.BASELINE_JSON_PATH = os.path.normpath(os.path.join(self.REGISTRY_PATH, "versions", "baseline.json"))
        # The test manifest should not be a persistent file, hence operate from a temporary directory.
        self.GENERATED_MANIFEST_PATH = options.manifest_path
        # Packages that are to be excluded from the CI run
        self.IGNORED_PACKAGES = set()  # TODO expose this as a command-line argument
        # The location into which vcpkg shall be checked out
        self.VCPKG_CLONE_PATH = options.vcpkg_clone_path
        self.VCPKG_ENV = {
            # vcpkg expects that it can resolve `$HOME` so we pretend that the manifest location is also the home folder
            'HOME': self.GENERATED_MANIFEST_PATH.name,
            # vcpkg expects that `PATH` is set
            'PATH': os.environ['PATH'],
            # Ensure that this registry's ports get used
            'VCPKG_OVERLAY_PORTS': os.path.join(self.REGISTRY_PATH, "ports"),
            'VCPKG_OVERLAY_TRIPLETS': os.path.join(self.REGISTRY_PATH, "triplets"),
            'VCPKG_ROOT': os.path.join(options.vcpkg_clone_path.name, "vcpkg"),
            # The vcpkg documentation recommends enabling asset and binary caching for those CI runs because they tend
            # to be very heavy.
            'VCPKG_BINARY_CACHE': "clear;",
            'X_VCPKG_ASSET_SOURCES': "clear;",
            "VCPKG_DEFAULT_TRIPLET": options.vcpkg_target_triplet,
            "VCPKG_DEFAULT_HOST_TRIPLET": options.vcpkg_host_triplet
        }

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        pass


def read_baseline_json(ctx: Configuration) -> dict:
    with open(ctx.BASELINE_JSON_PATH, "r") as fp:
        tmp = json.load(fp)
        return tmp["default"]


def write_manifest(ctx: Configuration, packages: dict):
    manifest = {
        "dependencies": [name for name in packages if name not in ctx.IGNORED_PACKAGES]
    }
    manifest_path = os.path.join(ctx.GENERATED_MANIFEST_PATH.name, "vcpkg.json")
    with open(manifest_path, "w") as fp:
        json.dump(manifest, fp)


def install_from_manifest(ctx: Configuration):
    try:
        subprocess.check_call([os.path.join(ctx.VCPKG_CLONE_PATH.name, "vcpkg", "vcpkg"), "install"], cwd=ctx.GENERATED_MANIFEST_PATH.name, env=ctx.ENV)
    except subprocess.CalledProcessError:
        ctx.GENERATED_MANIFEST_PATH._delete = False
        # Check if this failed because a port failed to install
        # In such an event, it's necessary to collect all relevant log files before the temporary folders get deleted
        """ example output
Installing 7/109 carbon-core:arm64-osx@2.4.0...
Building carbon-core:arm64-osx@2.4.0...
/Users/thomas/github.com/carbonengine/vcpkg-registry/ports/carbon-core: info: installing overlay port from here
-- Fetching git@github.com:carbonengine/core.git 5a01a587f703c49ede310ff9c9f039ad405789f3...
-- Extracting source /private/var/folders/dq/2vn_2nxj5bg401r07mg6h4800000gn/T/tmpm9za5459/vcpkg/downloads/carbon-core-5a01a587f703c49ede310ff9c9f039ad405789f3.tar.gz
-- Using source at /private/var/folders/dq/2vn_2nxj5bg401r07mg6h4800000gn/T/tmpm9za5459/vcpkg/buildtrees/carbon-core/src/ad405789f3-bab52b8a56.clean
-- Configuring arm64-osx
-- Building arm64-osx-dbg
CMake Error at scripts/cmake/vcpkg_execute_build_process.cmake:134 (message):
    Command failed: /private/var/folders/dq/2vn_2nxj5bg401r07mg6h4800000gn/T/tmpm9za5459/vcpkg/downloads/tools/cmake-3.31.10-osx/cmake-3.31.10-macos-universal/CMake.app/Contents/bin/cmake --build . --config Debug --target install -- -v -j15
    Working Directory: /private/var/folders/dq/2vn_2nxj5bg401r07mg6h4800000gn/T/tmpm9za5459/vcpkg/buildtrees/carbon-core/arm64-osx-dbg
    See logs for more information:
      /private/var/folders/dq/2vn_2nxj5bg401r07mg6h4800000gn/T/tmpm9za5459/vcpkg/buildtrees/carbon-core/install-arm64-osx-dbg-out.log

Call Stack (most recent call first):
  /private/var/folders/dq/2vn_2nxj5bg401r07mg6h4800000gn/T/tmp7trqvbdq/vcpkg_installed/arm64-osx/share/vcpkg-cmake/vcpkg_cmake_build.cmake:74 (vcpkg_execute_build_process)
  /private/var/folders/dq/2vn_2nxj5bg401r07mg6h4800000gn/T/tmp7trqvbdq/vcpkg_installed/arm64-osx/share/vcpkg-cmake/vcpkg_cmake_install.cmake:16 (vcpkg_cmake_build)
  /Users/thomas/github.com/carbonengine/vcpkg-registry/ports/carbon-core/portfile.cmake:23 (vcpkg_cmake_install)
  scripts/ports.cmake:206 (include)


error: building carbon-core:arm64-osx failed with: BUILD_FAILED        
        """
        raise


def clone_and_bootstrap_vcpkg(ctx: Configuration):
    subprocess.check_call(["git", "clone", "https://github.com/microsoft/vcpkg", os.path.join(ctx.VCPKG_CLONE_PATH.name, "vcpkg")])
    subprocess.check_call([os.path.join(ctx.VCPKG_CLONE_PATH.name, "vcpkg", "bootstrap-vcpkg.sh"), "-disableMetrics"])


def parse_command_line():
    command_line = argparse.ArgumentParser(description=str(__doc__),
                                           formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    command_line.add_argument('--manifest-path', type=tempfile.TemporaryDirectory, default=os.environ.get('REGISTRY_CI_GENERATED_MANIFEST_PATH', tempfile.TemporaryDirectory()))
    # Default to using a temporary directory for cloning the official registry. This is to ensure that the test won't
    # clobber nor accidentally rely on a pre-existing vcpkg installation's state.
    command_line.add_argument('--vcpkg-clone-path', type=tempfile.TemporaryDirectory, default=os.environ.get('REGISTRY_CI_VCPKG_CLONE_PATH', tempfile.TemporaryDirectory()))
    command_line.add_argument('--vcpkg-host-triplet', default=os.environ.get('REGISTRY_CI_VCPKG_HOST_TRIPLET', None))
    command_line.add_argument('--vcpkg-target-triplet', default=os.environ.get('REGISTRY_CI_VCPKG_TARGET_TRIPLET', None))
    return command_line.parse_args()


def main():
    options = parse_command_line()
    with Configuration(options) as ctx:
        packages = read_baseline_json(ctx)
        write_manifest(ctx, packages)
        clone_and_bootstrap_vcpkg(ctx)
        install_from_manifest(ctx)


"""
Things that need testing:
  - configuration, e.g. consumption of env vars / command-line args
  - manifest creation from baseline
  - forwarding of options to the vcpkg subprocess invocation
  - error handling
"""
class ConfigurationTests(unittest.TestCase):
    """
    Application configuration is assumed to follow a standard practice for 12-factor apps, e.g. have a
    default value that can be overridden through environment variables, which in turn can be overridden by a
    command-line switch.
    """
    def test_has_default_values(self):
        with patch.dict('os.environ', {
            'REGISTRY_CI_GENERATED_MANIFEST_PATH': '/generated/manifest/path',
            'REGISTRY_CI_VCPKG_CLONE_PATH': '/path/to/vcpkg',

        }):
            pass


class ContinuousIntegrationPipelineTest(unittest.TestCase):
    test_packages_dict = {
        "test-package": {"baseline": "1.2.3", "port-version": 1}, "test-package-2": { "baseline": "2024-12-12", "port-version": 0 }
    }
    expected_manifest_dict = {"dependencies": ["test-package", "test-package-2"]}
    expected_manifest_dict_without_test_package = {"dependencies": ["test-package-2"]}
    test_packages_string = '{"default":{"test-package": {"baseline": "1.2.3", "port-version": 1},"test-package-2": { "baseline": "2024-12-12", "port-version": 0 }}}'

    def setUp(self):
        self.config = Configuration(parse_command_line())

    @patch('builtins.open', mock_open(
        read_data=test_packages_string))
    def test_read_baseline_json(self):
        packages = read_baseline_json(self.config)
        self.assertIn("test-package", packages)
        self.assertIn("baseline", packages["test-package"])
        self.assertIn("port-version", packages["test-package"])

    def test_manifest_creation(self):
        mock_fp = mock_open()
        with patch('builtins.open', mock_fp):
            with patch('json.dump') as mock_object:
                write_manifest(self.config, self.test_packages_dict)
                mock_object.assert_called_once_with(self.expected_manifest_dict, mock_fp())

    def test_manifest_creation_ignores_packages(self):
        self.config.IGNORED_PACKAGES.add("test-package")
        mock_fp = mock_open()
        with patch('builtins.open', mock_fp):
            with patch('json.dump') as mock_object:
                write_manifest(self.config, self.test_packages_dict)
                mock_object.assert_called_once_with(self.expected_manifest_dict_without_test_package, mock_fp())


if __name__ == '__main__':
    main()
