
# Connecting to a AWS Instance in a private subnet using a Bastion host

## Introduction

This repo contains the required infrastructure to connect to an AWS Instance in a private subnet over a bastion host.

## Quick Start

To get started clone the repo:

```git clone https://github.com/satyasure/terraform-advanced.git```

The repo requires you to have an AWS profile called: personal. 

It is possible to change the profile name in the variables.tf file.

The next step is to generate the SSH keys. In the terraform directory create another directory called keys and create your keys with the following command:

```
# create the keys

ssh-keygen -f mykeypair
 
# add the keys to the keychain

ssh-add -K mykeypair  
```

## SSH Config File

$HOME/.ssh/config

```
Host bastion-instance
   HostName <Bastion Public IP>
   User ubuntu

Host private-instance
   HostName <Private IP>
   User ubuntu
   ProxyCommand ssh -q -W %h:%p bastion-instance
```

Amazon Virtual Private Cloud (Amazon VPC) enables you to launch AWS resources into a virtual network that you’ve defined. 

A subnet is a range of IP addresses within the VPC. 

Subnets can be either public with a gateway to the internet or private. 

Instances launched in a public subnet can send outbound traffic to the internet while instances launched in the private subnet can only do so via a network address translation (NAT) gateway in a public subnet. 

Naturally private subnets are more secure, as the management ports aren’t exposed to the internet. 

Typically in a modular web application, the front end web server will reside within the public subnet while the backend database is in the private subnet.

There are many reasons why connecting to instances in a private subnet is necessary:

The backend database for an application resides within a private subnet and an support Ops Engineer needs access to perform ad-hoc analysis.

The private subnet is whitelisted against another third-party service and it’s a requirement to interact with that service.


There are many reasons why connecting to instances in a private subnet is necessary:

The backend database for an application resides within a private subnet and an engineer needs access to perform ad-hoc analysis.

The private subnet is whitelisted against another third-party service and it’s a requirement to interact with that service.


## Connecting to a private subnet

Instances within the same VPC can connect to one another via their private IP addresses, as such it is possible to connect to an instance in a private subnet from an instance in a public subnet; otherwise known as a bastion host.

Amazon instances use SSH keys for authentication. As such connecting to the private instance will require a private key on the bastion host; in the same way connecting to the public instance requires a private key on your host machine, however this is extremely bad practise. 

Never expose your private keys to a bastion host!

An alternative solution is to use SSH agent forwarding, which allows a user to connect from the bastion to another instance without storing the private key on the bastion. 

An SSH agent is a program that keeps track of user’s identity keys and their pass phrases and can be configured with the following commands


# Generate SSH keys

ssh-keygen -k mykeypair

# Add the keys to your keychain

ssh-add -K mykeypair

Once the keys have been generated and added to the keychain, it is possible to connect to the bastion instance with SSH using the -A option. 

This enables forwarding and lets the local agent respond to the public-key challenge when connecting to instances from your bastion.

# Connect to the bastion host:

ssh -A <bastion-ip-address>

The next step is deploying the required infrastructure using Terraform.

## Infrastructure

The infrastructure below has been deployed using Terraform; an open-source infrastructure as code software (and the best thing since sliced bread!).

## Reference:
 
[medium](https://towardsdatascience.com/connecting-to-an-ec2-instance-in-a-private-subnet-on-aws-38a3b86f58fb)
 
## Author:
Satya Sure
