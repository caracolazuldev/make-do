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

### Using Modules
To integrate a make-do module into another make project, after you have added the module directory, install the module by adding it's name to a `.modules` file. The module can then be made by calling it as if it were a target in the parent make project.

Some modules will have additional functionality other than the default target. To see all of the targets available for a module use the `-C` flag to make to change to the module directory. Command completion will work without having to `cd` to the module directory.
e.g.
```
user@localhost:~/work/project$> make -C my-module optional-target
```

Modules also have the advantage of being able to share configuration files. You can declare all of your configuration variables in your project root, and the make-do modules will automatically pick them up. Be sure to `export` your vars. Copying any variable declarations from a module's `.defaults` file is a good way to get started. See more in the section on [Default Variable Initialization](#default-variable-initialization).

### make util-module-init
Once you have activated the framework for your make-file, you can initialize a directory as a make-do module simply by runing `make util-module-init` in the directory. This simply creates the standard files, if they don't already exist.

### Sub-makes are your friend
The use-case for modules came from some hard-won lessons about organizing make scripts. There are several options but they all have their trade-offs. Someone famously said, "Sub-Makes Considered Harmful"...so aren't make-do modules harmful?

The criticism against sub-makes is that for large build systems, it can be a performance issue when make can not build a full dependency graph because of sub-make calls. So, make-do's response to this rule of thumb is, "avoiding sub-makes is premature optimization." There is a lot of benefit in having re-usable components and even just nice organization for maintainability. Therefore, it is reasoned that for most cases, sub-makes have more benefits than harm.

## Default Variable Initialization
The `.defaults` file is auto-included, but only after any `.defaults` files in parent directories are loaded first. This is to allow intuitive behaviour for an integrated module when invoking make from inside the module directory. Another benefit is that defaults can be overridden without altering the module files themselves and if desired, can be versioned in the consuming project, while the module might be ignored by version control.

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
