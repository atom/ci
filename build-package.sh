#!/bin/sh

echo "Downloading latest Atom release..."
ATOM_CHANNEL="${ATOM_CHANNEL:=stable}"

if [ "${TRAVIS_OS_NAME}" = "osx" ]; then
  curl -s -L "https://atom.io/download/mac?channel=${ATOM_CHANNEL}" \
    -H 'Accept: application/octet-stream' \
    -o "atom.zip"
  mkdir atom
  unzip -q atom.zip -d atom
  if [ "${ATOM_CHANNEL}" = "stable" ]; then
    export ATOM_APP_NAME="Atom.app"
    export ATOM_SCRIPT_NAME="atom.sh"
    export ATOM_SCRIPT_PATH="./atom/${ATOM_APP_NAME}/Contents/Resources/app/atom.sh"
  else
    export ATOM_APP_NAME="Atom ${ATOM_CHANNEL}.app"
    export ATOM_SCRIPT_NAME="atom-${ATOM_CHANNEL}"
    export ATOM_SCRIPT_PATH="./atom-${ATOM_CHANNEL}"
    ln -s "./atom/${ATOM_APP_NAME}/Contents/Resources/app/atom.sh" "${ATOM_SCRIPT_PATH}"
  fi
  export ATOM_PATH="./atom"
  export APM_SCRIPT_PATH="./atom/${ATOM_APP_NAME}/Contents/Resources/app/apm/node_modules/.bin/apm"
  export NPM_SCRIPT_PATH="./atom/${ATOM_APP_NAME}/Contents/Resources/app/apm/node_modules/.bin/npm"
elif [ "${TRAVIS_OS_NAME}" = "linux" ]; then
  curl -s -L "https://atom.io/download/deb?channel=${ATOM_CHANNEL}" \
    -H 'Accept: application/octet-stream' \
    -o "atom-amd64.deb"
  /sbin/start-stop-daemon --start --quiet --pidfile /tmp/custom_xvfb_99.pid --make-pidfile --background --exec /usr/bin/Xvfb -- :99 -ac -screen 0 1280x1024x16
  export DISPLAY=":99"
  dpkg-deb -x atom-amd64.deb "${HOME}/atom"
  if [ "${ATOM_CHANNEL}" = "stable" ]; then
    export ATOM_SCRIPT_NAME="atom"
    export APM_SCRIPT_NAME="apm"
  else
    export ATOM_SCRIPT_NAME="atom-${ATOM_CHANNEL}"
    export APM_SCRIPT_NAME="apm-${ATOM_CHANNEL}"
  fi
  export ATOM_SCRIPT_PATH="${HOME}/atom/usr/bin/${ATOM_SCRIPT_NAME}"
  export APM_SCRIPT_PATH="${HOME}/atom/usr/bin/${APM_SCRIPT_NAME}"
  export NPM_SCRIPT_PATH="${HOME}/atom/usr/share/${ATOM_SCRIPT_NAME}/resources/app/apm/node_modules/.bin/npm"
elif [ "${CIRCLECI}" = "true" ]; then
  curl -s -L "https://atom.io/download/deb?channel=${ATOM_CHANNEL}" \
    -H 'Accept: application/octet-stream' \
    -o "atom-amd64.deb"
  sudo dpkg --install atom-amd64.deb || true
  sudo apt-get update
  sudo apt-get --fix-broken --assume-yes --quiet install
  export ATOM_SCRIPT_PATH="atom"
  export APM_SCRIPT_PATH="apm"
  export NPM_SCRIPT_PATH="/usr/share/atom/resources/app/apm/node_modules/.bin/npm"
else
  echo "Unknown CI environment, exiting!"
  exit 1
fi

echo "Using Atom version:"
"${ATOM_SCRIPT_PATH}" -v
echo "Using APM version:"
"${APM_SCRIPT_PATH}" -v

echo "Downloading package dependencies..."
"${APM_SCRIPT_PATH}" clean

if [ "${ATOM_LINT_WITH_BUNDLED_NODE:=true}" = "true" ]; then
  "${APM_SCRIPT_PATH}" install

  # Override the PATH to put the Node bundled with APM first
  if [ "${TRAVIS_OS_NAME}" = "osx" ]; then
    export PATH="./atom/${ATOM_APP_NAME}/Contents/Resources/app/apm/bin:${PATH}"
  elif [ "${CIRCLECI}" = "true" ]; then
    # Since CircleCI is a fully installed environment, we use the system path to apm
    export PATH="/usr/share/atom/resources/app/apm/bin:${PATH}"
  else
    export PATH="${HOME}/atom/usr/share/${ATOM_SCRIPT_NAME}/resources/app/apm/bin:${PATH}"
  fi
else
  export NPM_SCRIPT_PATH="npm"
  "${APM_SCRIPT_PATH}" install --production

  # Use the system NPM to install the devDependencies
  echo "Using Node version:"
  node --version
  echo "Using NPM version:"
  npm --version
  echo "Installing remaining dependencies..."
  npm install
fi

if [ -n "${APM_TEST_PACKAGES}" ]; then
  echo "Installing atom package dependencies..."
  for pack in ${APM_TEST_PACKAGES}; do
    "${APM_SCRIPT_PATH}" install "${pack}"
  done
fi

has_linter() {
  linter_module_path="$( ${NPM_SCRIPT_PATH} ls --parseable --dev --depth=0 "$1" 2> /dev/null )"
  [ -n "${linter_module_path}" ]
}

if has_linter "coffeelint"; then
  if [ -d ./lib ]; then
    echo "Linting package using coffeelint..."
    ./node_modules/.bin/coffeelint lib
    rc=$?; if [ $rc -ne 0 ]; then exit $rc; fi
  fi
  if [ -d ./spec ]; then
    echo "Linting package specs using coffeelint..."
    ./node_modules/.bin/coffeelint spec
    rc=$?; if [ $rc -ne 0 ]; then exit $rc; fi
  fi
fi

if has_linter "eslint"; then
  if [ -d ./lib ]; then
    echo "Linting package using eslint..."
    ./node_modules/.bin/eslint lib
    rc=$?; if [ $rc -ne 0 ]; then exit $rc; fi
  fi
  if [ -d ./spec ]; then
    echo "Linting package specs using eslint..."
    ./node_modules/.bin/eslint spec
    rc=$?; if [ $rc -ne 0 ]; then exit $rc; fi
  fi
fi

if has_linter "standard"; then
  if [ -d ./lib ]; then
    echo "Linting package using standard..."
    ./node_modules/.bin/standard "lib/**/*.js"
    rc=$?; if [ $rc -ne 0 ]; then exit $rc; fi
  fi
  if [ -d ./spec ]; then
    echo "Linting package specs using standard..."
    ./node_modules/.bin/standard "spec/**/*.js"
    rc=$?; if [ $rc -ne 0 ]; then exit $rc; fi
  fi
fi

if [ -d ./spec ]; then
  echo "Running specs..."
  "${ATOM_SCRIPT_PATH}" --test spec
elif [ -d ./test ]; then
  echo "Running specs..."
  "${ATOM_SCRIPT_PATH}" --test test
else
  echo "Missing spec folder! Please consider adding a test suite in './spec' or in './test'"
  exit 1
fi
exit
