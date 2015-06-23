# mesostack
Deploy [Mesosphere] (https://mesosphere.com)  on [Apache CloudStack] (http://www.cloudstack.org)

## Prerequisites
- CloudStack Advanced Zone
- Ubuntu 1404 template (see http://dl.openvm.eu/cloudstack/ubuntu/vanilla/14.04/x86_64/)

## Approach
First we build a Mesos image (CloudStack template) that contains the necessary mesosphere packages using [Packer](https://www.packer.io). For both master and slave nodes we use the same CloudStack template, although the slave requires only a subset of the master's software. To do this, we start with a base Ubuntu1404 image and install Mesosphere packages on it.

Once Packer creates a Mesos base template for us, we will use Terraform to create the Mesosphere cluster using  this base template to create the master and slave Mesos VMs

## Packer install
Create an Ubuntu base VM in a network in CloudStack. Install Packer on this VM. We'll call this VM the Packer VM.
Packer can be installed from https://www.packer.io. The CloudStack plugin can be installed from https://github.com/schubergphilis/packer-cloudstack.  Note that if you are building from scratch, as of end of June 2015, the build fails. To build successfully
```bash
export GOPATH=$HOME/go
mkdir -p $GOPATH
export PATH=$PATH:$GOPATH/bin
#assuming that Packer 0.7.5 has been installed in $GOPATH/bin
sudo apt-get -y install mercurial git bzr 
go get -u github.com/mitchellh/gox
go get -u github.com/schubergphilis/packer-cloudstack
cd $GOPATH/src/github.com/mitchellh/packer
make -C $GOPATH/src/github.com/schubergphilis/packer-cloudstack updatedeps dev
git checkout tags/v0.7.5
cd $GOPATH/src/github.com/schubergphilis/packer-cloudstack
[edit scripts/build.sh to comment out go get -u]
scripts/build.sh
cp pkg/linux_amd64/packer-cloudstack $GOPATH/bin
```

## Build Mesos Image using Packer
Copy `mesostack.json` from this repository to the Packer VM 
Edit the `builders` part of the Packer template (`mesostack.json`). Fill in the values for 
      `hypervisor`: xenserver has been tested
      `service_offering_id` : this is the service offering used by Packer to instantiate a new (Mesos) VM
      `template_id` : the CloudStack template id of the base Ubuntu template
      `zone_id` : zone where Packer will create the Mesos VM
      `disk_offering_id` : Any disk offering (shouldn't matter)
      `network_ids` : Network where Packer will create the Mesos VM. This is the same network as the Packer VM
We need the credentials to the CloudStack cloud.
```bash
export CLOUDSTACK_API_URL="http://cloudstack.local:8080/client/api"
export CLOUDSTACK_API_KEY="AAAAAAAAAAAAAAAAAA"
export CLOUDSTACK_SECRET_KEY="AAAAAAAAAAAAAAAAAA"
```
Execute
```bash
packer validate mesostack.json
packer build mesostack.json
```
If this works, you will have a brand new template called 'Ubuntu_mesos'.

## Build the Mesosphere cluster in an isolated network
We will use  [Terraform] (https://www.terraform.io) to deploy the Mesos template and create a Mesosphere cluster
