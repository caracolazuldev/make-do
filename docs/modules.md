# Make-do Modules

Make-do Modules are intended to be invoked as sub-makes. Make-do handles the sub-make invocation for you, as well as listing the module as an available target when using command (TAB) completion.

Your module should therefore have a single use-case that is also the default target. You can provide additional targets and use-cases, but they will not be automatically listed as a target for the make project that includes the module.

## Boilerplate

`mdo-util module-init`

Once you have activated the framework for your make-file, you can initialize a directory as a make-do module simply by running `mdo-util module-init` in the directory. This simply creates the standard files, if they don't already exist.

See the mdo-util [command reference](mdo-util.md).

## Directory Paths in Modules

You should always write your Make recipes assuming you are building in the current directory. Make-do unifies the build directories for sub-modules working together. When a module is invoked, the current directory is not changed and remains the parent directory of the module. If your module has build targets included in its distribution, you will want to set the module directory to be in the [VPATH that Make uses to find targets](https://www.gnu.org/software/make/manual/make.html#Directory-Search).

You can always have a reference to your module directory by way of the `${THIS_DIR}` variable provided by Make-do.

## Using Modules

To integrate a make-do module into another make project, after you have added the module directory, install the module by adding it's name to a `.modules` file. The module can then be made by calling it as if it were a target in the parent make project.

Note that when invoked as a sub-make, the build directory is not changed. This way, different modules can share a build directory. 

Some modules can have additional functionality other than the default target. To see all of the targets available for a module use the `-C` flag to `make` to change to the module directory. Command completion will work without having to `cd` to the module directory.
e.g.

```
user@localhost:~/work/project$> mdo -C my-module optional-target
```

## Setting Defaults

Environment variables will be loaded from a `.defaults` file in the root of your make-do module. This file can serve as a true default and does not need to be intended for editing. An integrator can provide a file of the same name in the directory directly above the module directory. See [Overriding Defaults](#overriding-defaults), below.

Read about make [variables in the make-guide](make-guide.md#variables).

Be sure to `export` your vars. 

## Overriding Defaults

Modules also have the advantage of being able to share configuration files. You can declare all of your configuration variables in your project root, and the make-do modules will automatically pick them up. 

Copying any variable declarations from a module's `.defaults` file is a good way to get started. See more in the section on [Default Variable Initialization](#default-variable-initialization).


