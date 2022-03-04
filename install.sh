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

sudo ${PWD}/venv/bin/python3 ${PWD}/geneva_tunnel.py
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

sudo ${PKGMGR} install -y git curl firefox build-essential python-dev libnetfilter-queue-dev libffi-dev libssl-dev iptables python3-pip

if ! command -v python3 >/dev/null 2>&1; then
  sudo ${PKGMGR} install -y python3 python3-virtualenv
fi
if command -v pip3 >/dev/null 2>&1; then
  python3 -m ensurepip --upgrade
fi

mkdir -p "${HOME}/git"
cd "${HOME}/git" && git clone https://github.com/Kkevsterrr/geneva && cd geneva
cp ${script_dir}/geneva_tunnel.py .
python3 -m virtualenv --clear -p python3 venv
. venv/bin/activate
pip3 install -r requirements.txt

cd "$script_dir" &&\
show_script | sudo tee /usr/local/bin/geneva &&\
sudo chmod +x /usr/local/bin/geneva


# install pip
# activate virtual environment
# pip install --upgrade pip
# pip install -r requirements.txt
