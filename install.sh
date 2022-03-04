#!/bin/sh

cd $(cd -P -- "$(dirname -- "$0")" && pwd -P)
geneva_files="/opt/geneva_files"
script_dir="/opt/geneva_files/geneva_tunnel"
old_dir="$PWD"

sudo mkdir -p "$geneva_files"
sudo chown -R "$LOGNAME" "$geneva_files"
cd "$geneva_files" && rm -rf "geneva_tunnel"
git clone https://github.com/0xdeadbeef0xbeefcafe/geneva_tunnel

set -e

if command -v apt-get >/dev/null 2>&1; then
  PKGMGR="apt-get"
elif command -v 'dnf' >/dev/null 2>&1; then
  PKGMGR="dnf"
elif command -v 'yum' >/dev/null 2>&1; then
  PKGMGR="yum"
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

cd "$geneva_files" && sudo rm -rf geneva
git clone https://github.com/Kkevsterrr/geneva
cd geneva && cp ${script_dir}/geneva .
sed -i "s/args\[opt\] is ''/args\[opt\] == ''/g" actions/utils.py
sudo -H python3 -m pip install -r requirements.txt
sudo -H python3 -m pip install --upgrade -U git+https://github.com/kti/python-netfilterqueue

set +e
sudo rm -rf /usr/local/bin/geneva
cd /usr/local/bin && sudo ln -sf /opt/geneva_files/geneva/geneva
sudo chmod +x /usr/local/bin/geneva
set -e

if [ -f /usr/lib/x86_64-linux-gnu/libc.a ]; then
  cd /usr/lib/x86_64-linux-gnu && sudo ln -sf libc.a liblibc.a
elif [ -f /usr/lib64/libc.a ]; then
  cd /usr/lib64 && sudo ln -sf libc.a liblibc.a
fi

sudo chown -R "$LOGNAME" "$geneva_files"

echo
echo "Installation finished."
echo "See usage by running 'sudo geneva -h'"
