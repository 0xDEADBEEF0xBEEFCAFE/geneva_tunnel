#!/bin/sh

set -e

cd $(cd -P -- "$(dirname -- "$0")" && pwd -P)

show_script() {
  cat <<EOF
#!/bin/sh

if [ "$1" = "-u" ] || [ "$1" = "--update" ]; then
  ${PWD}/update.sh
  exit
fi

cd "${HOME}/git/geneva"
sudo -H python3 geneva_tunnel.py
EOF
}

script_dir="$(pwd)"

if command -v apt-get >/dev/null 2>&1; then
  PKGMGR='apt-get'
elif command -v 'dnf' >/dev/null 2>&1; then
  PKGMGR='dnf'
elif command -v 'yum' >/dev/null 2>&1; then
  PKGMGR='yum'
fi
if ! command -v sudo >/dev/null 2>&1; then
  ${PKGMGR} update
  ${PKGMGR} install -y sudo
fi
if [ "$PKGMGR" = "apt-get" ]; then
  sudo ${PKGMGR} update
fi

sudo ${PKGMGR} install -y git curl build-essential python3-dev libnetfilter-queue-dev libffi-dev libssl-dev iptables python3-pip

if command -v firefox >/dev/null 2>&1; then
  FIREFOX=1
fi
if [ -z $FIREFOX ]; then
  if ! command -v firefox-esr >/dev/null 2>&1; then
    sudo ${PKGMGR} install -y firefox-esr
  fi
fi

if ! command -v python3 >/dev/null 2>&1; then
  sudo ${PKGMGR} install -y python3
fi
if command -v pip3 >/dev/null 2>&1; then
  curl -skLO 'https://bootstrap.pypa.io/get-pip.py'
  python3 get-pip.py && rm -f get-pip.py
fi

#pip3 install --upgrade virtualenv

mkdir -p "${HOME}/git"
cd "${HOME}/git" && sudo rm -rf geneva
git clone https://github.com/Kkevsterrr/geneva
cd geneva && cp ${script_dir}/geneva_tunnel.py .
#python3 -m virtualenv --clear -p python3 venv
#. venv/bin/activate
sudo -H python3 -m pip install -r requirements.txt
sudo -H python3 -m pip install --upgrade -U git+https://github.com/kti/python-netfilterqueue

show_script | sudo tee /usr/local/bin/geneva >/dev/null 2>&1
sudo chmod +x /usr/local/bin/geneva

if [ -f /usr/lib/x86_64-linux-gnu/libc.a ]; then
  cd /usr/lib/x86_64-linux-gnu && sudo ln -sf libc.a liblibc.a
elif [ -f /usr/lib64/libc.a ]; then
  cd /usr/lib64 && sudo ln -sf libc.a liblibc.a
fi
