# make-do
Make Build System Framework

Adds some helpful functions and variables to makefiles.

## Installation
```
git clone ...
cd make-do
make install
```

## Integration
Installation will put the framework into a standard search path for make includes.
You can activate the framework by putting `include make-do.mk` at the top of your makefile.

# Features

## Modules
A module is a make directory, that is, it contains a default-named, `Makefile` and a useful default target.
When you declare a module in a `.module` in your main make directory, make-do will auto-detect it as an available target. The module target will be listed when using the command (TAB) completion with make. Running the target will mean changing the working directory to the module and running the default target in a sub-make command.

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
