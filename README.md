# Atom Package CI Scripts

Templates for building your Atom package using [Travis CI](https://travis-ci.org).

## Setting up CI for your package

* Sign up for an account on [Travis CI](https://travis-ci.org)
* Copy this [.travis.yml](https://raw.githubusercontent.com/atom/ci/master/.travis.yml)
  to the root of your package's repository.
* Setup the [Travis hook](http://docs.travis-ci.com/user/getting-started/#Step-two%3A-Activate-GitHub-Webhook)
  on your package's repository.
* :boom: Your package will now build. You can see an example of a configured
  package [here](https://travis-ci.org/atom/wrap-guide).

## FAQ

### Why is the language set to objective-c?

Atom has only been released for Mac OS X and setting the `language` to
`objective-c` tells Travis to run the build on a Mac OS X worker. You can
read more about it [here](http://blog.travis-ci.com/introducing-mac-ios-rubymotion-testing).

### What version of Atom is used to run the specs?

It was always download the latest available version. You can read more about
the latest Atom release [here](https://atom.io/releases).

### How does it it work?

The `.travis.yml` template downloads the [build-package.sh](https://raw.githubusercontent.com/atom/ci/master/build-package.sh)
from this repository.  This script then downloads node, the latest Atom release,
and runs the `apm test` command to run your package's specs. You can run
`apm help test` to learn more about that command.

The `apm test` command assumes your package is using [Jasmine](http://jasmine.github.io)
specs. You can run the specs locally using Atom's spec runner UI from the
_View > Developer > Run Package Specs_ menu or by pressing `cmd-ctrl-alt-p`.

### What does the output look like?

Take a look at an example package build [here](https://travis-ci.org/atom/wrap-guide/builds/23774579).

### What packages use this?

Click [here](https://github.com/search?q=https%3A%2F%2Fraw.githubusercontent.com%2Fatom%2Fci%2Fmaster%2Fbuild-package.sh+path%3A.travis.yml&type=Code) to
see all the Atom packages with Travis CI enabled.
