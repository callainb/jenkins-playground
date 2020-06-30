# jenkins-playground
Two projects in this repo

1) Master and slave (main.tf file)

2) Docker build to build a small SSH 'server' to be used with Jenkins for experimenting...
BEFORE we docker build:

We need to run "ssh-keygen -f remusr" it will create remusr and remusr.pub
However, newer version of openssh generated newer armor which is incompatible with SSH plugin...
Use "ssh-keygen -f remusr -m PEM" instead

Docker build

sudo docker build -t remhst .

Run

# See https://runnable.com/docker/binding-docker-ports
sudo docker run -rm --d --name remhst -p 2222:22 remhst 

# To log in on port 2222
ssh -i ./remusr ssh://remusr@127.0.0.1:2222
