# shellcheck shell=bash

# Increase containers log size, if needed
#sed -i -e's/ "10m"/ "100m"/' /etc/docker/daemon.json && systemctl restart docker

install_kubectl{
    curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.25.9/2023-05-11/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
    echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
}

install_kubectl