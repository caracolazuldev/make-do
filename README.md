# make-do
Make Build System Framework

Adds some helpful functions and variables to makefiles.

## Installation
Installation is system-wide.
```
git clone ...
cd make-do
make install
```

If you want to use make-do without installing system-wide, you will need to ensure that it is in the make includes search directories and set MAKE_DO_INSTALL in make-do.mk.

## Integration
Installation will put the framework into a standard search path for make includes.
You can activate the framework by putting `include make-do.mk` at the top of your makefile.

# Features

## Modules
Make-do Modules are intended to be invoked as sub-makes. Make-do handles the sub-make invocation for you, as well as listing the module as an available target when using command (TAB) completion.

Your module should therefore have a single use-case that is also the default target. You can provide additional targets and use-cases, but they will not be automatically listed as a target for the make project that includes the module.

### make util-module-init
You can initialize a directory as a make-do module, after integrating the framework (by `include`), simply by runing `make util-module-init`. This simply creates the standard files, if they don't already exist.

## Default Variable Initialization
The `defaults` file is auto-included, but only after any `.defaults` files in parent directories are loaded first. This is to allow intuitive behaviour for an integrated module when invoking make from inside the module directory. Another benefit is that defaults can be overridden without altering the module files themselves and if desired, can be versioned in the consuming project, while the module might be ignored by version control.

Note, any directory not containing a `.defaults` file, including the first directory searched, will cause the directory tree crawl to be stopped. It is recommended that your re-usable modules contain a `.defaults` file, even if it is un-used. Not having a `.defaults` file will prevent `.defaults` files in parent directories from loading.

## Environment Validation
Two means of validating that variables are set and generating errors are available.

On a target, declare the variable dependency as a target prerequisite.
Use as an order-only prerequisite, i.e. after a pipe (|) character.
e.g. `target: prereq | require-env-BUILD_HOME`

Globally in a Makefile, you can call the require-env function:
`$(call require-env, PROJ_ROOT)`

## User Input
More to come...
Can currently ask a user for confirmation.
```$(call user-confirm, Would you like to continue?)```

## Configuration
Not integrated yet, but the `util/macro.mk` file contains a function for rendering variables from the environment using a template.
