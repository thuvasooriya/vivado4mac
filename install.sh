#!/bin/zsh

# echo with color
function f_echo {
  echo -e "\e[1m\e[33m$1\e[0m"
}

script_dir=$(dirname -- "$(readlink -nf $0)")

# check internet connectivity
if ! ping -q -c1 google.com &>/dev/null; then
  f_echo "Could not connect to the internet. Recheck and run ./install again."
  exit 1
fi

# check if docker is installed
# if ! [ -d "/Applications/Docker.app" ]
# 	then
# 		f_echo "You need to install Docker first."
# 		exit 1
# fi

# check if xquartz is installed
# if ! [ -d "/Applications/Utilities/XQuartz.app" ]
# 	then
# 		f_echo "You need to install XQuartz first."
# 		exit 1
# fi

# change xquartz settings, otherwise no x11 connection from container possible
defaults write org.xquartz.X11 no_auth 1
defaults write org.xquartz.X11 nolisten_tcp 0
defaults write org.nixos.xquartz.X11 no_auth 1
defaults write org.nixos.xquartz.X11 nolisten_tcp 0

# vivado seems to be using glx
defaults write org.xquartz.X11 enable_iglx -bool true
defaults write org.nixos.xquartz.X11 enable_iglx -bool true

# launch docker daemon and xquartz
f_echo "Launching Docker daemon and XQuartz..."
open -a XQuartz

# wait for docker to start
while ! docker ps &>/dev/null; do
  open -a Docker
  sleep 5
done

# build the docker image according to the dockerfile
f_echo "Building Docker image"
docker build -t x64-linux .

# copy vivado installation file into $script_dir
# installation_binary=""
# while ! [[ $installation_binary == *.bin ]]
# do
# 	f_echo "Drag and drop the installation binary into this terminal window and press Enter: "
# 	read installation_binary
# done
# cp $installation_binary $script_dir

# copy vivado installation file into $script_dir if it is not already there
found_installation_binary=$(find $script_dir -name "*.bin")
if [ -z "$found_installation_binary" ]; then
  installation_binary=""
  while ! [[ $installation_binary == *.bin ]]; do
    f_echo "drag and drop the installation binary into this terminal window and press enter: "
    read installation_binary
  done
  cp $installation_binary $script_dir
else
  f_echo "found installation binary"
fi

# running install script in docker container
f_echo "launching docker container and installation script"
/usr/local/bin/docker run -it --init --rm --mount type=bind,source="/tmp/.X11-unix",target="/tmp/.X11-unix" --mount type=bind,source="$script_dir",target="/home/user" --platform linux/amd64 x64-linux bash /home/user/docker.sh

# create app icon
f_echo "generating app icon"
input_file=$(find Xilinx/Vivado/*/doc/images/vivado_logo.png)
mkdir icon.iconset
sips -z 16 16 "$input_file" --out "icon.iconset/icon_16x16.png"
sips -z 32 32 "$input_file" --out "icon.iconset/icon_16x16@2x.png"
sips -z 32 32 "$input_file" --out "icon.iconset/icon_32x32.png"
sips -z 64 64 "$input_file" --out "icon.iconset/icon_32x32@2x.png"
sips -z 128 128 "$input_file" --out "icon.iconset/icon_128x128.png"
sips -z 256 256 "$input_file" --out "icon.iconset/icon_128x128@2x.png"
sips -z 256 256 "$input_file" --out "icon.iconset/icon_256x256.png"
sips -z 512 512 "$input_file" --out "icon.iconset/icon_256x256@2x.png"
sips -z 512 512 "$input_file" --out "icon.iconset/icon_512x512.png"
iconutil -c icns icon.iconset
rm -rf icon.iconset
mv icon.icns Vivado.app/Contents/Resources/icon.icns

# create vivado script; needed for getting script path
# launch xquartz and docker
echo '#!/bin/zsh\nopen -a XQuartz\nopen -a Docker\nwhile ! /usr/local/bin/docker ps &> /dev/null\ndo\nopen -a Docker\nsleep 5\ndone\nwhile ! [ -d "/tmp/.X11-unix" ]\ndo\nopen -a XQuartz\nsleep 5\ndone\n' >Vivado.app/Vivado
# run docker container by starting hw_server first to establish an xvc connection and then vivado
echo "/usr/local/bin/docker run --init --rm --name vivado_container --mount type=bind,source=\"/tmp/.X11-unix\",target=\"/tmp/.X11-unix\" --mount type=bind,source=\""$script_dir"\",target=\"/home/user\" --platform linux/amd64 x64-linux sudo -H -u user bash /home/user/start_vivado.sh &" >>Vivado.app/Vivado
# launch xvc server on host
# echo "osascript -e 'tell app \"Terminal\" to do script \" while "'!'" [[ \$(ps aux | grep vivado_container | wc -l | tr -d \\\"\\\\\\\n\\\\\\\t \\\") == \\\"1\\\" ]]; do "$script_dir"/xvcd/bin/xvcd; sleep 1; done; exit\"'" >> Vivado.app/Vivado
chmod +x Vivado.app/Vivado
