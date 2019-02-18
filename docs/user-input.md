# User Input

Can currently ask a user for confirmation.
```$(call user-confirm, Would you like to continue?)```

You can prompt the user within a recipe, or when the Makefile is first loaded.

See the section on [variables](variables.md) to declare a variable that is required. If you do not set a default, then an error will be generated and inform the user that the variable must be set.