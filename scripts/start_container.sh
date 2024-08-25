#!/bin/zsh

# starts the docker container and xvcd for usb forwarding

script_dir=$(dirname -- "$(readlink -nf $0)")
source "$script_dir/header.sh"
validate_macos

# this is called when the container stops or ctrl+c is hit
function stop_container {
  docker kill vivado_container >/dev/null 2>&1
  f_echo "stopped docker container"
  killall xvcd >/dev/null 2>&1
  f_echo "stopped xvcd"
  exit 0
}
trap 'stop_container' INT

# make sure everything is setup to run the container
start_docker
if [[ $(docker ps) == *vivado_container* ]]; then
  f_echo "there is already an instance of the container running."
  exit 1
fi
killall xvcd >/dev/null 2>&1

# run container
docker run --init --rm --name vivado_container --mount type=bind,source="$script_dir/..",target="/home/user" -p 127.0.0.1:5901:5901 --platform linux/amd64 x64-linux sudo -H -u user bash /home/user/scripts/linux_start.sh &
f_echo "started container"
sleep 3
f_echo "starting vnc viewer"
vncpass=$(tr -d "\n\r\t " <"$script_dir/vncpasswd")
osascript -e "tell application \"Screen Sharing\" to GetURL \"vnc://user:$vncpass@localhost:5901\""
f_echo "running xvcd for usb forwarding..."
# while vivado_container is running
while [[ $(docker ps) == *vivado_container* ]]; do
  # if there is a running instance of xvcd
  if pgrep -x "xvcd" >/dev/null; then
    :
  else
    eval "$script_dir/xvcd/bin/xvcd > /dev/null 2>&1 &"
    sleep 2
  fi
done
stop_container

