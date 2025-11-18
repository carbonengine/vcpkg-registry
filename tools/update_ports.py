import os, subprocess, argparse, sys

FAIL_COLOUR = '\033[91m'
OKCYAN_COLOUR = '\033[96m'
OKGREEN_COLOUR = '\033[92m'
END_COLOUR = '\033[0m'

if __name__ == "__main__":
    registry_root = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))

    # Get VCPKG_ROOT from environment variable
    vcpkg_root = os.environ.get("VCPKG_ROOT")
    if not vcpkg_root:
        sys.exit(f"{FAIL_COLOUR}VCPKG_ROOT environment variable is not set. Please set it to the location of the Microsoft vcpkg root directory.{END_COLOUR}")

    vcpkg_exe_filename = "vcpkg"
    if os.name == 'nt':
        vcpkg_exe_filename = "vcpkg.exe"

    vcpkg_tool = os.path.abspath(os.path.join(vcpkg_root, vcpkg_exe_filename))
    if not os.path.isfile(vcpkg_tool):
        sys.exit(f"{FAIL_COLOUR}vcpkg executable not found at {vcpkg_tool}. Please check your VCPKG_ROOT environment variable and make sure you have run the vcpkg bootstrap script.{END_COLOUR}")

    initial_git_status = subprocess.run(["git", "status", "--porcelain=v1"], capture_output=True, check=True, cwd=registry_root)
    if initial_git_status.stdout != b'':
        sys.exit(f"{FAIL_COLOUR}There are uncommited changes in {registry_root}. Either commit or stash any changes to your branch and run this script again{END_COLOUR}")

    print("formating all manifest files")
    try:
        subprocess.run([vcpkg_tool, "format-manifest", "--all", f"--vcpkg-root={vcpkg_root}"], check=True, cwd=registry_root)
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
            f"--vcpkg-root={vcpkg_root}"],
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
