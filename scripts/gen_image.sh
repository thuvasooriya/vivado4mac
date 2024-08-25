#!/bin/zsh

# generate the docker image

script_dir=$(dirname -- "$(readlink -nf $0)")
source "$script_dir/header.sh"
validate_macos

start_docker

# build the docker image according to the dockerfile
f_echo "building docker image..."
if ! docker build -t x64-linux "$script_dir"; then
  f_echo "docker image generation failed!"
  exit 1
fi

f_echo "the docker image was successfully generated."

