#!/bin/bash
echo "In USER DATA script - USER DATA - USER DATA"

# Install openjdk...
sudo apt-get update
sudo apt install -y software-properties-common apt-transport-https
#sudo add-apt-repository -y ppa:openjdk-r/ppa
sudo apt-get install -y openjdk-11-jdk-headless

# We add a Jenkins user done with provisionners...
#useradd -m -s /bin/bash jenkins
#passwd jenkins

# Install docker
sudo apt install -y docker.io
# Add jenkins to docker group so it can execute docker commands...
# done in provisioner
#sudo usermod -a -G docker jenkins
#
# echo -e required to have the newlines using bash... but -e with sh displays the -e... may use printf otherwise
echo -e '{\n  "debug" : true,\n  "bip" : "10.30.0.1/24"\n}' | sudo tee /etc/docker/daemon.json
sudo systemctl restart docker
sudo systemctl enable docker
