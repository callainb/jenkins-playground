#!/bin/bash
echo "In USER DATA script - USER DATA - USER DATA"

# Install openjdk...
sudo apt-get update
sudo apt-get install -y openjdk-11-jdk-headless

# Install jenkins
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 9B7D32F2D50582E6
sudo apt-get update
sudo apt-get install -y jenkins
# NOTE: The import of 9B7D32F2D50582E6 above is to avoid these errors on apt-get update
#W: GPG error: https://pkg.jenkins.io/debian-stable binary/ Release: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY 9B7D32F2D50582E6
#E: The repository 'http://pkg.jenkins.io/debian-stable binary/ Release' is not signed.
#N: Updating from such a repository can't be done securely, and is therefore disabled by default.

# This does not works at the package jenkins does not exist...
#wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
#sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
#sudo apt-get update
#sudo apt-get install -y jenkins

#sudo systemctl status jenkins
