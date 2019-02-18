# make-do

A framework for Make build systems, adds utilities for configuration management and user input. Keep build tasks organized as modules and invoke them as targets.

## Shell commands

Quickly create shell commands using a framework based on the Make build system. Wrap any script in a module and create auto-complete (bash_completion) sub-commands from any make target or module. Modules help you manage configurations and defaults, command line interface, and are readily installable.

### `mdo`

The `mdo` command can be a helpful wrapper to the make command. You should only use the wrapper on your make-do projects because it disables the common built-ins that will be required for building most uses of `make` but rarely used for make-do projects. Honestly, this command doesn't do very much right now, since global features were moved to `mdo-util`. Use mdo to confirm that the default generated command wrapper for your command will properly build your make project. 

### `mdo-util`

Generate make-do framework boilerplate and other features. 

[Read the docs](docs/mdo-util.md).

## Install as a system command

```
git clone ...
cd make-do
make install
```

### Installing on a mac

You will have to ensure the following prerequisites:

- Bash 4+ (with bash_completions)
- Gnu Make

You can install bash and make using Homebrew. 

- https://superuser.com/questions/31744/how-to-get-git-completion-bash-to-work-on-mac-os-x/31753
- https://troymccall.com/better-bash-4--completions-on-osx/

[Help wanted: complete guide for mac installation.]

## Build-System Sub-Modules

If you install make-do globally, it will put the framework into a standard search path for make includes. You can activate the framework by putting `include make-do.mk` at the top of your makefile.

If you want to use make-do without installing system-wide, you will need to ensure that it is in the make includes search directories and set MAKE_DO_INSTALL in make-do.mk.

### In defense of sub-makes

The use-case for modules came from some hard-won lessons about organizing make scripts. There are several options but they all have their trade-offs. Someone famously said, "Sub-Makes Considered Harmful"...so aren't make-do modules harmful?

The criticism against sub-makes is that for large build systems, it can be a performance issue when make can not build a full dependency graph because of sub-make calls. So, make-do's response to this rule of thumb is, "avoiding sub-makes is premature optimization." There is a lot of benefit in having re-usable components and even just nice organization for maintainability. Therefore, it is reasoned that for most cases, sub-makes have more benefits than harm.

## Writing Commands

Why write commands using make, you ask? 

- fastest and easiest command completion setup - every make-target is automatically suggestable.
- Declarative programming is the highest of high-level programming. Just let go of those control structures, and gain back that time spent debugging  conditionals. Make works hard to decide the execution order for you. If you find yourself writing conditionals, or struggling with it in recipes, stop - you really may not need to. Often what you need instead of a conditional is a prerequisite.  Learn more in the [Make Guide](docs/make-guide.md).
- environment variables make for light-weight parameters. It may seem strange at first to not use terse flags or double-hyphen parameters, but you quickly realize how convenient it is to just set variables in the shell. 
- Highly extensible. Easily integrate other tools through the shell.

See the [mdo-util guide](docs/mdo-util.md) to get started writing commands with make-do.

## User Input

[More to come...](docs/user-input.md)
Can currently ask a user for confirmation.
```$(call user-confirm, Would you like to continue?)```

## Configuration 
Coming soon. See the [roadmap](docs/roadmap.md) for discussion of adding template rendering to make-do.
