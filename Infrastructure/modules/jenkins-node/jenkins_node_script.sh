#!/usr/bin/env bash
#!/bin/bash
#kubectl
sudo apt update
sudo apt install snapd
sudo snap install kubectl --channel=1.21/stable --classic
#helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
sudo chmod 700 get_helm.sh
sudo ./get_helm.sh

#jenkins slave node
sudo apt install openjdk-11-jdk -y
sudo mkdir /opt/jenkins-slave
sudo chown ubuntu:ubuntu /opt/jenkins-slave -R

#aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install

#install docker
sudo apt install docker.io -y
sudo systemctl enable docker
sudo systemctl status docker
sudo usermod -aG docker ubuntu