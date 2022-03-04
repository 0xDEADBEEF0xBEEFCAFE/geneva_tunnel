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

sudo ${HOME}/git/geneva/venv/bin/python3 ${HOME}/git/geneva/geneva_tunnel.py
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

pip3 install --upgrade virtualenv

mkdir -p "${HOME}/git"
cd "${HOME}/git" && rm -rf geneva
git clone https://github.com/Kkevsterrr/geneva
cd geneva && cp ${script_dir}/geneva_tunnel.py .
python3 -m virtualenv --clear -p python3 venv
. venv/bin/activate
pip3 install -r requirements.txt

show_script | sudo tee /usr/local/bin/geneva >/dev/null 2>&1
sudo chmod +x /usr/local/bin/geneva
