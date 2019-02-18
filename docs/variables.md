# Working With Variables

## Provided by Make-Do

* `THIS_DIR` - the location of the module files.
* `MAKE_DO_INSTALL` - the location of the make-do library
* `MODULES_DEF_FILE` - `$(THIS_DIR)`/.modules
* `MODULES` - result of loading the .modules file, if it exists.

## Default Variable Initialization

The `.defaults` file is auto-included, but only after any `.defaults` files in parent directories are loaded first. This is to allow intuitive behaviour when not invoking as a sub-make, i.e. from within the directory itself. Another benefit is that defaults can be overridden without altering the module files themselves and if desired, can be versioned in the consuming project, while the module might be ignored by version control.

Be sure to use the conditional (if-empty) assignment operator ` ?= ` in .defaults files unless you want to disable the ability to override the variable.

Note, any directory not containing a `.defaults` file, will cause the directory tree crawl to be stopped.

## Environment Validation

Two means of validating that variables are set and generating errors are available.

On a target, declare the variable dependency as a target prerequisite.
Use as an [order-only prerequisite](make-guide.md#prerequisites), i.e. after a pipe (|) character.
e.g. `target: prereq | require-env-BUILD_HOME`

Globally in a Makefile, you can call the require-env function:
`$(call require-env, PROJ_ROOT)`
