import os, subprocess, argparse, sys

FAIL_COLOUR = '\033[91m'
OKCYAN_COLOUR = '\033[96m'
OKGREEN_COLOUR = '\033[92m'
END_COLOUR = '\033[0m'

if __name__ == "__main__":
    registry_root = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
    vcpkg_submodule_path = os.path.join(registry_root, "vendor", "github.com", "microsoft", "vcpkg")
    vcpkg_exe_filename = "vcpkg"
    if os.name == 'nt':
        vcpkg_exe_filename = "vcpkg.exe"

    vcpkg_tool = os.path.abspath(os.path.join(vcpkg_submodule_path, vcpkg_exe_filename))

    try:
        print("updating submodules ...")
        subprocess.run(["git", "submodule", "update", "--init"], capture_output=True, check=True, cwd=registry_root)
        print(f"{OKCYAN_COLOUR}submodules updated successfully{END_COLOUR}")
    except subprocess.CalledProcessError as e:
        sys.exit()
    print(vcpkg_tool)
    if not os.path.isfile(vcpkg_tool):
        print(f"{OKCYAN_COLOUR}vcpkg executable not detected{END_COLOUR}")
        script_suffix = ".sh"
        if os.name == 'nt':
            script_suffix = ".bat"

        bootstrap_tool = "bootstrap-vcpkg" + script_suffix
        print(f"running {bootstrap_tool} from {vcpkg_submodule_path} ...")
        subprocess.run([os.path.join(vcpkg_submodule_path, bootstrap_tool)], cwd=vcpkg_submodule_path, check=True)

    initial_git_status = subprocess.run(["git", "status", "--porcelain=v1"], capture_output=True, check=True, cwd=registry_root)
    if initial_git_status.stdout != b'':
        sys.exit(f"{FAIL_COLOUR}There are uncommited changes in {registry_root}. Either commit or stash any changes to your branch and run this script again{END_COLOUR}")

    print("formating all manifest files")
    try:
        subprocess.run([vcpkg_tool, "format-manifest", "--all", f"--vcpkg-root={registry_root}"], check=True, cwd=registry_root)
    except subprocess.CalledProcessError as e:
        sys.exit(e.stderr)

    # format-manifest may change line endings to lf. This causes an erroneous change in the working tree on windows when
    # core.autocrlf = true. Adding to staging before checking for changes will filter out these erroneous results as the
    # index will always contain lf line endings.
    subprocess.run(["git", "add", "."], cwd=registry_root, capture_output=True, check=True)
    git_status = subprocess.run(["git", "status", "--porcelain=v1"], capture_output=True, check=True, cwd=registry_root)
    porcelain = git_status.stdout.decode("utf-8")

    if porcelain != "":
        print(f"format changes detected, creating formatting commit ...")
        subprocess.run(["git", "commit", "-m 'Apply automated formatting'"], cwd=registry_root, capture_output=True, check=True)
        print(f"{OKCYAN_COLOUR}added changes to commit:\n{porcelain}{END_COLOUR}")
    else:
        print(f"no format changes detected")

    print("running vcpkg command ...")
    try:
        subprocess.run(
            [vcpkg_tool, "--x-builtin-ports-root=./ports",
            "--x-builtin-registry-versions-dir=./versions",
            "x-add-version",
            "--all",
            "--verbose",
            f"--vcpkg-root={vcpkg_submodule_path}"],
            cwd=registry_root,
            check=True
        )
    except subprocess.CalledProcessError as e:
        sys.exit(e.stderr)


    git_status = subprocess.run(["git", "status", "--porcelain=v1"], capture_output=True, check=True, cwd=registry_root)
    porcelain = git_status.stdout.decode("utf-8")
    if porcelain == "":
        sys.exit(f"{OKCYAN_COLOUR}no changes were generated{END_COLOUR}")


    subprocess.run(["git", "add", "."], cwd=registry_root, capture_output=True, check=True)
    git_status = subprocess.run(["git", "status", "--porcelain=v1"], capture_output=True, check=True, cwd=registry_root)
    porcelain = git_status.stdout.decode("utf-8")
    package_names = []
    for line in porcelain.split('\n'):
        if (line.startswith("M") or line.startswith("A")) and not "baseline.json" in line:
            filename = os.path.split(line[2:])[-1]
            package_name = filename.split(".")[0]
            if line.startswith("M"):
                package_names.append(f"Update {package_name}")
            elif line.startswith("A"):
                package_names.append(f"Add {package_name}")

    commit_message = f"Update version registry\n\nThis is an automatically generated version update for the following packages:\n{"\n".join(package_names)}"
    print(f"generated commit:\n---------------------------------------------------------------------------\n{OKCYAN_COLOUR}{commit_message}{END_COLOUR}\n---------------------------------------------------------------------------\n")
    try:
        subprocess.run(["git", "commit", "-m", commit_message], check=True, cwd=registry_root, capture_output=True)
    except subprocess.CalledProcessError as e:
        sys.exit(e.stderr)

    print(f"{OKGREEN_COLOUR}Done{END_COLOUR}")
