#!/bin/bash

echo "Downloading latest Atom release..."
ATOM_CHANNEL="${ATOM_CHANNEL:=stable}"
[ "$TRAVIS_OS_NAME" == "osx" ] && ATOM_DOWNLOAD_URL="https://atom.io/download/mac?channel=$ATOM_CHANNEL" || ATOM_DOWNLOAD_URL="https://atom.io/download/deb?channel=$ATOM_CHANNEL"
[ "$TRAVIS_OS_NAME" == "osx" ] && ATOM_DOWNLOAD_FILE=atom.zip || ATOM_DOWNLOAD_FILE=atom.deb

curl -s -L "$ATOM_DOWNLOAD_URL" \
  -H 'Accept: application/octet-stream' \
  -o "$ATOM_DOWNLOAD_FILE"

if [ "$TRAVIS_OS_NAME" == "osx" ]
then
    mkdir atom
    unzip -q atom.zip -d atom
    if [ "$ATOM_CHANNEL" == "stable" ]
    then
      export CI_ATOM_APPNAME="Atom.app"
      export CI_ATOM_SCRIPTNAME="atom.sh"
      export CI_ATOM_SH="./atom/${CI_ATOM_APPNAME}/Contents/Resources/app/atom.sh"
    else
      export ATOM_CHANNEL_CAMELCASE="$(tr '[:lower:]' '[:upper:]' <<< ${ATOM_CHANNEL:0:1})${ATOM_CHANNEL:1}"
      export CI_ATOM_APPNAME="Atom ${ATOM_CHANNEL_CAMELCASE}.app"
      export CI_ATOM_SCRIPTNAME="atom-${ATOM_CHANNEL}"
      export CI_ATOM_SH="./atom-${ATOM_CHANNEL}"
      ln -s "./atom/${CI_ATOM_APPNAME}/Contents/Resources/app/atom.sh" "${CI_ATOM_SH}"
    fi
    export PATH="$PWD/atom/${CI_ATOM_APPNAME}/Contents/Resources/app/apm/bin:$PATH"
    export ATOM_PATH="./atom"
    export CI_APM_SH="./atom/${CI_ATOM_APPNAME}/Contents/Resources/app/apm/node_modules/.bin/apm"
else
    /sbin/start-stop-daemon --start --quiet --pidfile /tmp/custom_xvfb_99.pid --make-pidfile --background --exec /usr/bin/Xvfb -- :99 -ac -screen 0 1280x1024x16
    export DISPLAY=":99"
    sudo apt-get update -qq
    sudo apt-get install build-essential -qq
    sudo apt-get install git -qq
    sudo apt-get install libgnome-keyring-dev -qq
    sudo apt-get install fakeroot -qq
    sudo apt-get install gconf2 -qq
    sudo apt-get install gconf-service -qq
    sudo apt-get install libgtk2.0-0 -qq
    sudo apt-get install libudev1 -qq
    sudo apt-get install libgcrypt20 -qq
    sudo apt-get install libnotify4 -qq
    sudo apt-get install libxtst6 -qq
    sudo apt-get install libnss3 -qq
    sudo apt-get install python -qq
    sudo apt-get install gvfs-bin -qq
    sudo apt-get install xdg-utils -qq
    sudo apt-get install libcap2 -qq
    sudo apt-get install gdebi-core -qq
    sudo apt-get update -qq
    sudo gdebi -n atom.deb
    if [ "$ATOM_CHANNEL" == "stable" ]
    then
      export CI_ATOM_SCRIPTNAME="atom"
      export CI_APM_SCRIPTNAME="apm"
    else
      export CI_ATOM_SCRIPTNAME="atom-$ATOM_CHANNEL"
      export CI_APM_SCRIPTNAME="apm-$ATOM_CHANNEL"
    fi
    export CI_ATOM_SH="/usr/bin/$CI_ATOM_SCRIPTNAME"
    export CI_APM_SH="/usr/bin/$CI_APM_SCRIPTNAME"
fi


echo "Using Atom version:"
/bin/bash "$CI_ATOM_SH" -v
echo "Using APM version:"
/bin/bash "$CI_APM_SH" -v

echo "Downloading package dependencies..."
/bin/bash "$CI_APM_SH" clean
/bin/bash "$CI_APM_SH" install

TEST_PACKAGES="${APM_TEST_PACKAGES:=none}"

if [ "$TEST_PACKAGES" != "none" ]; then
  echo "Installing atom package dependencies..."
  for pack in $TEST_PACKAGES ; do
    /bin/bash "$CI_APM_SH" install $pack
  done
fi

if [ -f ./node_modules/.bin/coffeelint ]; then
  if [ -d ./lib ]; then
    echo "Linting package..."
    ./node_modules/.bin/coffeelint lib
    rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
  fi
  if [ -d ./spec ]; then
    echo "Linting package specs..."
    ./node_modules/.bin/coffeelint spec
    rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
  fi
fi

if [ -f ./node_modules/.bin/eslint ]; then
  if [ -d ./lib ]; then
    echo "Linting package..."
    ./node_modules/.bin/eslint lib
    rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
  fi
  if [ -d ./spec ]; then
    echo "Linting package specs..."
    ./node_modules/.bin/eslint spec
    rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
  fi
fi

if [ -f ./node_modules/.bin/standard ]; then
  if [ -d ./lib ]; then
    echo "Linting package..."
    ./node_modules/.bin/standard lib/**/*.js
    rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
  fi
  if [ -d ./spec ]; then
    echo "Linting package specs..."
    ./node_modules/.bin/standard spec/**/*.js
    rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
  fi
fi

echo "Running specs..."
/bin/bash "$CI_ATOM_SH" --test spec
exit
