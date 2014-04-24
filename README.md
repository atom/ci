# Atom Package CI Scripts

Templates for building your Atom package using [Travis CI](https://travis-ci.org).

Copy the [.travis.yml](https://raw.githubusercontent.com/atom/ci/master/.travis.yml)
to the root of your package's repository and then setup the [Travis hook](http://docs.travis-ci.com/user/getting-started/#Step-two%3A-Activate-GitHub-Webhook)
to get your package building.

The [build-package.sh](https://raw.githubusercontent.com/atom/ci/master/build-package.sh)
script downloads the latest version of Atom and runs your package's specs using
the `apm test` command.
