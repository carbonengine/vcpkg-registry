# Posix Sysconfig Vars None

The sysconfig module provides information about the Python build configuration. This gets done by importing a Python file that gets generated at buildtime.

This generated Python file contains one variable called build_time_vars, which is a dict, and provides a bunch of build specific information which we don't really need, and might change frequently between builds, so we don't want to publish it to Perforce.

However, we have some nonessential code that calls `sysconfig.get_config_vars()` and expects a result. Since without the generated Python file this call results in an `ImportError`, we make the function that loads these variables into a no-op.