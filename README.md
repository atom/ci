# Atom Package CI Scripts

Templates for building your Atom package and running its specs:

* OS X: Using [Travis CI](https://travis-ci.org)
* Windows: Using [AppVeyor](http://appveyor.com)

## Setting up CI for your package

### Travis CI

* Sign up for an account on [Travis CI](https://travis-ci.org)
* Copy [.travis.yml](https://raw.githubusercontent.com/atom/ci/master/.travis.yml)
  to the root of your package's repository
* Setup the [Travis CI hook](http://docs.travis-ci.com/user/getting-started/#Step-two%3A-Activate-GitHub-Webhook) on your package's repository
* :boom: Your package will now build and run its specs; you can see an example
  of a configured package [here](https://travis-ci.org/atom/wrap-guide)

### AppVeyor

* Sign up for an account on [AppVeyor](http://appveyor.com)
* Add a new project
* Ensure the **Ignore appveyor.yml** setting in *Settings > General* is unchecked
* Copy [appveyor.yml](https://raw.githubusercontent.com/atom/ci/master/appveyor.yml)
  to the root of your package's repository
* :boom: Your package will now build and run its specs; you can see an example
  of a configured package [here](https://ci.appveyor.com/project/joefitzgerald/go-plus)

## FAQ

### Why is the language set to objective-c for Travis CI?

Atom has only been released for Mac OS X and Windows and setting the `language`
to `objective-c` tells Travis CI to run the build on a Mac OS X worker. You can
read more about it [here](http://blog.travis-ci.com/introducing-mac-ios-rubymotion-testing).

### What version of Atom is used to run the specs?

It will always download the latest available version. You can read more about
the latest Atom release [here](https://atom.io/releases).

### How does it work?

The `apm test` command assumes your package is using [Jasmine](http://jasmine.github.io)
specs. You can run the specs locally using Atom's spec runner UI from the
_View > Developer > Run Package Specs_ menu or by pressing `cmd-ctrl-alt-p`. You
can run `apm help test` to learn more about that command.

#### Travis CI

The `.travis.yml` template downloads the [build-package.sh](https://raw.githubusercontent.com/atom/ci/master/build-package.sh)
from this repository. This script then downloads node, the latest Atom release,
and runs the `apm test` command to run your package's specs.

#### AppVeyor

The `appveyor.yml` template uses [Chocolatey](https://chocolatey.org/) to
download and install the [latest version of Atom](https://chocolatey.org/packages/Atom).
`apm install` is run in your package directory to ensure any node dependencies
are available. Finally, the script runs the `apm test` command to run your
package's specs.

### What does the output look like?

* [OS X @ Travis CI](https://travis-ci.org/atom/wrap-guide/builds/23774579)
* [Windows @ AppVeyor](https://ci.appveyor.com/project/kevinsawicki/wrap-guide/build/2)

### What packages use this?

* [OS X @ Travis CI](https://github.com/search?q=https%3A%2F%2Fraw.githubusercontent.com%2Fatom%2Fci%2Fmaster%2Fbuild-package.sh+path%3A.travis.yml&type=Code)
* [Windows @ AppVeyor](https://github.com/search?q="cinst+atom"+extension%3Ayml&type=Code)
