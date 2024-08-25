# general functions and definitions used by the other scripts

# this script needs to be sourced into other scripts or
# be run explicitly with an interpreter since it has no shebang

script_dir=$(dirname -- "$(readlink -nf $0)")
source "$script_dir/hashes.sh"

# echo with color
function f_echo {
  echo -e "\e[1m\e[33m$1\e[0m"
}

# aborts the script if it isn't run on macOS
function validate_macos {
  if [[ $(uname) == *Darwin* ]]; then
    :
  else
    f_echo "make sure to run this script on macos."
    exit 1
  fi
}

# aborts the script if it isn't run inside the Docker container
function validate_linux {
  if [[ $(uname) == *Linux* ]]; then
    :
  else
    f_echo "make sure to run this script on linux."
    exit 1
  fi
}

function wait_for_user_input {
  f_echo "press enter to continue..."
  read
}

function start_docker {
  # check if docker is installed
  if ! which docker &>/dev/null; then
    f_echo "you need to install docker first."
    exit 1
  fi

  # launch docker daemon
  f_echo "launching docker daemon..."
  # sleep 2
  # wait for docker to start
  # while ! docker ps &>/dev/null; do
  # open -a Docker
  # sleep 5
  # done
  # sleep 2
}

function stop_docker {
  curl -s -X POST -H 'Content-Type: application/json' -d '{ "openContainerView": true }' -kiv --unix-socket "$HOME/Library/Containers/com.docker.docker/Data/backend.sock" http://localhost/engine/stop &>/dev/null
  osascript -e 'quit app "Docker Desktop"'
  sleep 2
}

vivado_version=""

function set_vivado_version_from_hash {
  if [[ -v web_hashes[$1] ]]; then
    vivado_version=${web_hashes[$1]}
  elif [[ -v sfd_hashes[$1] ]]; then
    vivado_version=${sfd_hashes[$1]}
  else
    f_echo "Invalid installer hash"
    exit 1
  fi
  return 0
}

# the actual resolution is stored in the file vnc_resolution
vnc_default_resolution="1920x1080"

current_user=$(whoami)
