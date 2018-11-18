# make-do

Quickly create shell commands using a framework based on the make build system. Wrap any script in a module and create auto-complete (bash_completion) sub-commands from any make target or module. Modules help you manage configurations and defaults, command line interface, and are readily installable.

A framework for make build systems, adds utils for configuration management and user input. Keep build tasks organized as modules and invoke them as targets.

<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [make-do](#make-do)
	- [Installation](#installation)
	- [Integration](#integration)
- [Utilities](#utilities)
- [Modules](#modules)
	- [Using Modules](#using-modules)
	- [mdo util-module-init](#mdo-util-module-init)
	- [Sub-makes are your friend](#sub-makes-are-your-friend)
- [Variables](#variables)
	- [Default Variable Initialization](#default-variable-initialization)
	- [Environment Validation](#environment-validation)
- [User Input](#user-input)
- [Configuration](#configuration)

<!-- /TOC -->

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

# Utilities

The `mdo` command will give you access to make-do utilities and generators. You can also use it as an alias for make.

* `util-generate-cmd`: create a wrapper command for your make-do module
* `util-install-cmd`: creates a link /usr/local/bin to your command wrapper, and installs a command completion script for you. See the make-do [completions][047213c8] file for an example. Completion sugestions will be the targets in your module.
* `util-module-init`: generates starter files for your module.

Use command completion with the mdo command (`mdo util-<TAB><TAB>`) to list all of the utilities included in `make-do`.

  [047213c8]: completions "completions"

# Modules
Make-do Modules are intended to be invoked as sub-makes. Make-do handles the sub-make invocation for you, as well as listing the module as an available target when using command (TAB) completion.

Your module should therefore have a single use-case that is also the default target. You can provide additional targets and use-cases, but they will not be automatically listed as a target for the make project that includes the module.

## Using Modules
To integrate a make-do module into another make project, after you have added the module directory, install the module by adding it's name to a `.modules` file. The module can then be made by calling it as if it were a target in the parent make project.

Some modules will have additional functionality other than the default target. To see all of the targets available for a module use the `-C` flag to make to change to the module directory. Command completion will work without having to `cd` to the module directory.
e.g.
```
user@localhost:~/work/project$> mdo -C my-module optional-target
```

Modules also have the advantage of being able to share configuration files. You can declare all of your configuration variables in your project root, and the make-do modules will automatically pick them up. Be sure to `export` your vars. Copying any variable declarations from a module's `.defaults` file is a good way to get started. See more in the section on [Default Variable Initialization](#default-variable-initialization).

## mdo util-module-init
Once you have activated the framework for your make-file, you can initialize a directory as a make-do module simply by runing `mdo util-module-init` in the directory. This simply creates the standard files, if they don't already exist.

## Sub-makes are your friend
The use-case for modules came from some hard-won lessons about organizing make scripts. There are several options but they all have their trade-offs. Someone famously said, "Sub-Makes Considered Harmful"...so aren't make-do modules harmful?

The criticism against sub-makes is that for large build systems, it can be a performance issue when make can not build a full dependency graph because of sub-make calls. So, make-do's response to this rule of thumb is, "avoiding sub-makes is premature optimization." There is a lot of benefit in having re-usable components and even just nice organization for maintainability. Therefore, it is reasoned that for most cases, sub-makes have more benefits than harm.

# Variables

## Default Variable Initialization
The `.defaults` file is auto-included, but only after any `.defaults` files in parent directories are loaded first. This is to allow intuitive behaviour when not invoking as a sub-make, i.e. from within the directory itself. Another benefit is that defaults can be overridden without altering the module files themselves and if desired, can be versioned in the consuming project, while the module might be ignored by version control.

Be sure to use the conditional (if-empty) assignment operator ` ?= ` in .defaults files unless you want to disable the ability to override the variable.

Note, any directory not containing a `.defaults` file, will cause the directory tree crawl to be stopped.

## Environment Validation
Two means of validating that variables are set and generating errors are available.

On a target, declare the variable dependency as a target prerequisite.
Use as an order-only prerequisite, i.e. after a pipe (|) character.
e.g. `target: prereq | require-env-BUILD_HOME`

Globally in a Makefile, you can call the require-env function:
`$(call require-env, PROJ_ROOT)`

# User Input
More to come...
Can currently ask a user for confirmation.
```$(call user-confirm, Would you like to continue?)```

# Configuration
Help wanted. See #11, integrating Jinja Templating.
