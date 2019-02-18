# Roadmap



## Configuration Approach

To use make-do for configuration management, we need to fortify the interface between make and the environment. 

We want to set state via all methods:

- command line arguments
- exported environment variables
- default initializations from a standard file
- by building new configuration files

Make does not have available any multi-dimensional or complex structured state storage. We can compensate for the lack of complex objects by causing an intermediate configuration file, e.g. a YAML file, to be updated or generated based on parameters or initialization state. This complex state configuration can then be rendered by a template engine in a make target recipe.

### Twig Template Rendering

* Marshall state from environment
* State Transformation
* Rendering

Requirements:

- Twig library via an autoloader
- Instantiate twig and read-in environment
- Load a template

Potentially to read from standard input: https://twig.symfony.com/doc/2.x/recipes.html#loading-a-template-from-a-string

More Template Loaders:https://twig.symfony.com/doc/2.x/api.html#loaders

https://twig.symfony.com/doc/2.x/api.html#escaper-extension

https://twig.symfony.com/doc/2.x/api.html#sandbox-extension

## Serialization Interfaces

We do not need to work with serialized data in Make build files directly. Instead, we should have tools that can work with the objects in the appropriate execution environment for the format.

- YAML
- JSON

We can use re-usable recipes to load a file serialized file, execute a transformation, and pipe the resulting serialized state to either be rendered or written back to the filesystem.

## Harness Other Task Runners

- Composer
- NPM https://www.npmjs.com/package/fakefile
- Grunt & Gulp (Naaah)

## Configure Library Install

There are hard-coded configurations in several places. When we integrate template rendering, we should make the framework install process environment aware.