# python-customizations
> Patches for all customizations applied to our fork of Python

# Usage

Run the `customize.py` script. For further details see below:

```shell
> python customize.py -h 
usage: customize.py [-h] [-v] [-s SOURCES] [-p PATCHES] [-a APPLY [APPLY ...]]
                    [-i IGNORE [IGNORE ...]] [-d]

Apply Python customizations

This script requires `git` to be available in the environment.

It returns 0 if all requested patches were successfully applied.

In case of an error, the following exit codes may be returned:
  90 = the `git` command cannot be executed
  91 = one or more of the requested patches failed to apply
  92 = there were no patches to apply

optional arguments:
  -h, --help            show this help message and exit
  -v, --verbose         Verbose output, useful for debugging.
                        (default: False)
  -s SOURCES, --sources SOURCES
                        Location of the Python sources to which the patches should be applied.
                        (default: C:\Users\thomas\github.com\ccpgames\python-customizations)
  -p PATCHES, --patches PATCHES
                        Location of the Patch files that should be applied to Python
  -a APPLY [APPLY ...], --apply APPLY [APPLY ...]
                        Patch files to apply.
                        (default: all patch files are applied)
  -i IGNORE [IGNORE ...], --ignore IGNORE [IGNORE ...]
                        Patch files to ignore, even if they are matched by one of the --apply filters.
                        (default: no patch files are ignored).
  -d, --dry-run         Perform a dry run, e.g. only check if patches can be applied.
                        (default: False)
```

# How to create a patch file

Since Python is using git the process for creating a patch is straight forward using standard git operations.
Consider the following example:

```shell
# clone repo
> git clone https://github.com/ccpgames/cpython.git
# check out the relevant branch, f.e. the 3.8 slp branch
> git checkout 3.8-slp
# Make some modification
> echo "Just for demonstration purposes, not a good patch!" >example.md && git add example.md
# Create the patch (this will consider staged and unstaged changes)
> git diff HEAD >example.patch
# The above diff command will create a patch using staged and unstaged changes.
# If you want only unstaged changes, simply usg `git diff`, or use `git diff --staged` to only consider staged changes.
```

# How to apply a patch file

This is a simple git operation as well:

```shell
> git apply example.patch
```

In case you want to check if a patch can be applied at all, the following command can be used:

```shell
# this will print two error messages and return a non-zero exit code if example.patch was already applied
> git apply --check example.patch
```

Which results in the following chain of commands to apply a patch only if it wasn't applied yet:

```shell
# this checks if the patch can be reversed (will print two error messages if it cannot), otherwise applies it
> git apply -R --check example.patch || git apply example.patch
```

# How to contribute a patch

Use [GitHub flow](https://docs.github.com/en/get-started/quickstart/github-flow) to [contribute to](https://docs.github.com/en/get-started/quickstart/contributing-to-projects) this repository.
