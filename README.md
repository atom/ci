# Atom Package CI Scripts

Templates for building your Atom package and running its specs:

* macOS and Ubuntu Linux: Using [Travis CI](https://travis-ci.org)
* Windows: Using [Appveyor](https://appveyor.com)
* Ubuntu Linux: Using [CircleCI](https://circleci.com)

## Setting up CI for your package

### Travis CI

* Sign up for an account on [Travis CI](https://travis-ci.org)
* Copy [.travis.yml](https://raw.githubusercontent.com/atom/ci/master/.travis.yml)
  to the root of your package's repository
* Setup the [Travis CI hook](https://docs.travis-ci.com/user/getting-started/#To-get-started-with-Travis-CI%3A) on your package's repository
* :boom: Your package will now build and run its specs; you can see an example
  of a configured package [here](https://travis-ci.org/atom/wrap-guide)

### Appveyor

* Sign up for an account on [Appveyor](https://appveyor.com)
* Add a new project
* Ensure the **Ignore appveyor.yml** setting in *Settings > General* is unchecked
* Copy [appveyor.yml](https://raw.githubusercontent.com/atom/ci/master/appveyor.yml)
  to the root of your package's repository
* :boom: Your package will now build and run its specs; you can see an example
  of a configured package [here](https://ci.appveyor.com/project/Atom/wrap-guide)

### CircleCI

* Sign up for an account on [CircleCI](https://circleci.com)
* [Add a new project](https://circleci.com/docs/getting-started)
* Copy [circle.yml](https://raw.githubusercontent.com/atom/ci/master/circle.yml) to the root of your package's repository
* :boom: Your package will now build and run its specs; you can see an example of a configured package [here](https://circleci.com/gh/AtomLinter/linter-stylelint)

## FAQ

### How do I install other Atom packages that my package build depends on?

Set the `APM_TEST_PACKAGES` environment variable in your `.travis.yml` or `circle.yml` file
to a space-separated list of packages to install before your package's tests
run.

```yml
env:
  - APM_TEST_PACKAGES="autocomplete-plus some-other-package-here"
```

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
from this repository. This script then downloads the latest Atom release,
installs your package's dependencies, and runs the `apm test` command to run
your package's specs.

#### Appveyor

The `appveyor.yml` template uses [Chocolatey](https://chocolatey.org/) to
download and install the [latest version of Atom](https://chocolatey.org/packages/Atom).
`apm install` is run in your package directory to ensure any node dependencies
are available. Finally, the script runs the `apm test` command to run your
package's specs.

#### CircleCI

The `circle.yml` template runs the same script that is used in the Travis-CI builds.


### What does the output look like?

* [macOS @ Travis CI](https://travis-ci.org/atom/wrap-guide/builds/23774579)
* [Windows @ Appveyor](https://ci.appveyor.com/project/Atom/wrap-guide/build/12)
* [Ubuntu Linux @ CircleCI](https://circleci.com/gh/AtomLinter/linter-stylelint/623)

### What packages use this?

* [macOS and Ubuntu Linux @ Travis CI and CircleCI](https://github.com/search?utf8=%E2%9C%93&q=%22curl+-s+https%3A%2F%2Fraw.githubusercontent.com%2Fatom%2Fci%2Fmaster%2Fbuild-package.sh+|+sh%22+extension%3Ayml&type=Code)
* [Windows @ Appveyor](https://github.com/search?q="cinst+atom"+extension%3Ayml&type=Code)
