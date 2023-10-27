#!/bin/bash

# Exit handler
control_c () {
	kill $PID
	exit
}

trap control_c SIGINT SIGTERM

# Flag gets
DEV=false
GAZEBO=false

while getopts "ds" flag; do
	case $flag in
		d)
			DEV=true
			;;
		s)
			GAZEBO=true
			;;
		*)
			echo 'Usage: $0 [-d] [-s]'
			exit 1
			;;
	esac
done

# Header
if [ "$DEV" = true ]; then
	echo "Installing ROS2 Iron with dev tools..."
else
	echo "Installing ROS2 Iron..."
fi

if [ -z "$ROS_DISTRO" ]; then
	# Locale setup
	sudo apt update && sudo apt install locales -y
	sudo locale-gen en_US en_US.UTF-8
	sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
	export LANG=en_US.UTF-8

	# Sources setup
	sudo apt install software-properties-common -y
	sudo apt-add-repository universe -y

	# GPG key setup
	sudo apt update && sudo apt install curl -y
	sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

	# Repository setup
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

	# System preparation
	sudo apt update
	sudo apt upgrade -y

	# ROS2 installation
	sudo apt install ros-iron-desktop -y

	echo '' >> ~/.bashrc
	echo '# ROS2 stuff' >> ~/.bashrc
	echo 'alias iron="source /opt/ros/iron/setup.bash"' >> ~/.bashrc
	echo '' >> ~/.bashrc
	echo 'iron' >> ~/.bashrc
elif [ "$ROS_DISTRO" != "iron" ]; then
	echo "Another version of ROS is already installed! Please uninstall it first"
else
	echo "ROS2 Iron already installed, skipping..."
fi

if [ "$DEV" = true ]; then
	sudo apt install ros-dev-tools -y
fi

# Simulation
if [ "$GAZEBO" = true ]; then
	# Gazebo source setup
	sudo sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list'
	curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
	sudo apt-get update -y

	# Gazebo installation
	sudo apt install ros-iron-ros-gz -y
fi
