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

## Overview

The source of each include is the best reference. Here is an incomplete list of some of the includes, and what they provide.

* `require.mk-do` - A way to require that a variable is set, and if not, print an error message and exit.
* `wp.mk-do` - utilities for Wordpress developers
* `config.mk-do` - create configuration files from templates
* `embed-awk.mk-do` - embed awk scripts in a Makefile
* `container-registry.mk-do` - build, tag, and publish docker images
* `compose.mk-do` - wrapper for docker-compose
* `git.mk-do` - manage a directory of git repositories and perform global actions on them.
* `help.mk-do` - utils for adding help documentation to Makefiles