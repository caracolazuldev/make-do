# Writing Make Files

An overly-short make tutorial.

## Rules have three parts:

* Target
* Prerequisites
* Recipe

## Have a look at some example rules, from simple to complex:
Copy one directory to another, ensuring that both directories exist. The first as a prerequisite of the target. The target itself using a shell command.
```
dist: build
  ( [ -d dist ] || mkdir dist ) && \
  cp -a build dist
```
Install a system package. Note, this recipe will always be run if invoked or named as a prerequisite (because it is marked as PHONY).
```
.PHONY: install-libmysql-java
install-libmysql-java:
	dpkg -S libmysql-javas || sudo apt install libmysql-java
```
Start a service conditionally after a check defined in a make variable (`ping-solr`). Note, the if-true clause is not defined, because we want to execute if-false.
```
ping-solr = $(shell curl http\://$(SOLR_HOST)\:$(SOLR_PORT)/api/collections \
--fail 2>/dev/null 1>/dev/null && \
echo solr started)

.PHONY: start
start:
	$(if $(ping-solr), , $(SOLR_BIN)/solr start -cloud )
```
https://www.gnu.org/software/make/manual/make.html#Conditional-Functions

## Targets
...are things that make ensures to exist and be valid. They are declared by being at the beginning of a line and terminated with a colon. Targets can also be defined by make variables `$(IM_A_MAKE_VARIABLE)`, wildcard (%) pattern matching, or file-names. Multiple targets can be specified for one rule (recipe), which can also serve to alias targets.

## Prerequisites

Prerequisites are other targets. They are listed after the colon and on the same line as the target. You can use a line continuation if you don't like side-scrolling. Make doesn't care how long your lines are and you can use make variables also to declare prerequisite.

Declare the dependency between targets by listing them after the colon in the target name.

[GNU Make Manual:: Prerequisite Types](https://www.gnu.org/software/make/manual/make.html#Prerequisite-Types)

### Order-only Prerequisites

Prerequisites declared after a pipe will not cause the target to be re-built if they are missing or are newer than the target. 

## Recipes
...come after a target and must be indented.

Each line of a recipe is interpreted first by make. This way, you can actually generate shell commands. You don't need to escape much when writing recipes. Everything interpreted by make will be inside of a `$()`. However, you do need to escape dollar-signs in your shell commands with a double-dollar-sign `$$`.

See the dirs: target for an example of using a make for-loop to generate shell commands from a list of names in a make variable.

Each line of a recipe is invoked in it's own `/bin/sh -c`. If you don't want to write a script, and `&&` your commands together and make it inteligible with line-continuations `\`. Note, the line continuation, though the same as shell, is interpreted and removed by the make preprocessor.

Commands in recipes are echo'd by make before they are passed to `/bin/sh -c`. You can disable this with a leading aroba (@).

Since echo is implicit, you will see messages to the user that simply start with a hash (#). Yes, you can use make variables and functions in these comments. Make doesn't see these as comments and they are dutifully passed to the shell.

## Variables
The convention is that variables that are inherited from the environment, or are exported by your make script, should be all-caps (you know, like env variables...).

If you are only using the variable locally, it should be all-lowercase.

Variables can be dereferenced either with parenthesis or curl-braces. We encourage using curl-braces for variables and parenthesis for expressions.

### Environment
If you want to allow overriding a variable in the environment, you should conditionally initialize it.

```
ENV ?= STAGE
```
Export variables to the shell used to execute recipes just like in shell scripts

```
export MY_VAR
```
You can then override such variables by exporting them in your shell before running make, or, more commonly, setting them in command-line options to make.
```
make SHELL=/bin/dash
```

### Assignment
There is an important distinction between the two most common assignment types. The default is known as the "recursive assignment" operator because it will not be evaluated until the variable is used.
```
my-var = $(shell echo 'I am lazy loaded')
```
The second type of assignment operator is the "immediate" assignment, which are considered beneficial for performance.
```
my-var := $(shell echo 'I am executed before any recipes use me')
```
Reference
* https://www.gnu.org/software/make/manual/make.html#Flavors

## Shell Portability
Yes, a recipe is just shell commands. Note, _shell_ commands, i.e., NOT BASH, `/bin/sh`. Calm down, you don't want bash-isms in your recipes. Write a script and do all the fancy shyte you can think of and call your script in the recipe.

Install the utility `checkbashisms` and use it to find non-portable code in your shell scripts. The Makefile in this repo declares `SHELL := sh` for the sake of portability. It is recommended that you set your system to use use dash in place of sh, the default on debian-type systems.

## Misc.
* add `--trace` to your invocation for debugging.
* dump to console using  the info function: `$(info message about $my_var)`
* Error 127 means file not found... you have a typo, dummy.
* If you want to call out to the shell from inside of a make function call, use the make function $(shell ...). See dirs: target for a simple example.
* Recipes can be interactive, execution will pause for user input. Use with caution, as it will impact parallel execution and the ability to integrate into, e.g., continuous build systems.
* It is easy to over-complicate recipes until you get used to the fact that make is made for files. If a file exists, and it isn't considered out of date, then the recipe for that target will not be run. If you catch yourself writing a test for a file... stop and make it a dependency. Then define the recipe to create that dependency of the recipe you were working on.
* As mentioned above, if you define a virtual target that does not create a file, there is the danger of a collision with a real file that will prevent your virtual target from executing. Add the target to the .PHONY target to prevent the collision with a real file.
* WARNING: You can't use make [ conditionals](https://www.gnu.org/software/make/manual/make.html#Conditionals) in recipes. You can use them to dynamically define recipes, but they will be executed before the recipe interpretation starts. Note that they are not indented, to indicate they are not part of recipes. See [conditional functions](https://www.gnu.org/software/make/manual/make.html#Conditional-Functions) for use in recipes.

## Resources
* http://clarkgrubb.com/makefile-style-guide
* https://www.shellcheck.net/
* http://shellhaters.org/ - POSIX shell reference
* https://linux.die.net/man/1/checkbashisms
* https://www.gnu.org/software/make/manual/make.html#Special-Targets
* https://www.gnu.org/software/make/manual/make.html#Automatic-Variables
* https://www.gnu.org/software/make/manual/make.html#Recipes
* https://www.gnu.org/software/make/manual/make.html#Functions
* https://www.gnu.org/software/make/manual/make.html#Make-Control-Functions
* https://www.gnu.org/software/make/manual/make.html#Shell-Function
* https://www.gnu.org/software/make/manual/make.html#File-Name-Functions
* https://www.gnu.org/software/make/manual/make.html#Quick-Reference
* https://www.gnu.org/software/make/manual/make.html#Error-Messages
* https://www.gnu.org/software/make/manual/make.html#Concept-Index
* https://www.gnu.org/software/make/manual/make.html#Name-Index (keywords known to make)