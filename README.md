# make-do

A collection of Makefile includes that can be dropped-in to a project to add Make rules. Install the library globally, or selectively copy the includes into your project.

## Install global make includes

```
git clone ...
make install
```

You can manually add files from the includes/ directory to your project. Alternatively, you can use the install command to add the includes to a standard search path for make includes. The location is set by...
```make
MAKE_INCLUDES_PATH ?= /usr/local/include/#
```

### Installing via Homebrew


- https://superuser.com/questions/31744/how-to-get-git-completion-bash-to-work-on-mac-os-x/31753
- https://troymccall.com/better-bash-4--completions-on-osx/

## Version 1.0 of this library

The goal of this project changed significantly. Version 1.0 aimed for more than a collection of copy-paste includes for Makefiles. The attempt to create a module system was probably mis-guided. Another goal was to facilitate using make to create light-weight CLI commands, including with bash completions. The bash completion snippits is a straightforward example of how to write bash completions, even outside of Makefiles.

## Include Index

The source of each include is the best reference. Here is an incomplete list of some of the includes, and what they provide.

* `auto-includes.mk-do` - DEPRECATED: it's good to declare your dependencies.
* `cli.mk-do` - CLI user interaction utils.
* `compose.mk-do` - Manage docker compose with file partials and a replacement "profile" feature.
* `config.mk-do` - Create configuration files from templates.
* `container-registry.mk-do` - Build/Tag (and optionally publish) Docker images.
* `embed-awk.mk-do` - Embed an awk script into a Makefile.
* `git.mk-do` - Manage a directory of git repositories and perform global actions on them.
* `help.mk-do` - Define a target called, help, using a README if found.
* `modules.mk-do` - Modular Makefile Framework (Deprecated? - needs work)
* `require.mk-do` - Utilities to require that a variable is set, and if not, print an error message and exit.
* `wp.mk-do` - Utilities for Wordpress developers.
