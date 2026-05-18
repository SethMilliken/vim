#!/usr/bin/env zsh
EXPECTED_PYTHON="3.14.4"

function python_check() {
  local actual="$(python3 --version | awk -e '{print $2}')"
  if [[ ! $EXPECTED_PYTHON == $actual ]]; then
    echo "Python version changed from ${EXPECTED_PYTHON} to ${actual}. Doing clean build."
    echo "Update $(basename $0) with new expected version."
    make distclean
  else
    echo "Python version is still ${EXPECTED_PYTHON}."
  fi
}

function do_install() {
  local datestamp="$(date +%Y-%m-%d)"
  sudo make install && git tag -f araxia && git tag -f araxia-${datestamp}
}

case $1 in
  install)
    do_install
    exit 0
    ;;
esac

python_check

git fetch --all
git rebase origin/master

./configure                                                           \
              --with-features=huge                                    \
              --enable-python3interp                                  \
              --with-python3-config-dir=$(python3-config --configdir) \
              --prefix=/usr/local

cd src
make

printf "To install: $(basename 0) install\n"
