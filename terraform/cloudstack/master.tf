
resource "cloudstack_egress_firewall" "network01" {
  network = "${var.cs_network_name}"
  depends_on = ["cloudstack_network.network01", "cloudstack_instance.master"]

  rule {
    source_cidr = "0.0.0.0/0"
    protocol = "tcp"
    ports = ["1-65535"]
  }

  rule {
    source_cidr = "0.0.0.0/0"
    protocol = "udp"
    ports = ["1-65535"]
  }

  rule {
    source_cidr = "0.0.0.0/0"
    protocol = "icmp"
    icmp_type = "-1"
    icmp_code = "-1"
  }
}

resource "cloudstack_firewall" "master_ssh" {
  ipaddress = "${cloudstack_ipaddress.public_ip.id}"
  depends_on = ["cloudstack_instance.master"]
  count = "${var.num_masters}"

  rule {
    source_cidr = "0.0.0.0/0"
    protocol = "tcp"
    ports = ["${count.index+var.master_ssh_port_start}"]
  }
}

resource "cloudstack_firewall" "mesos_marathon" {
  ipaddress = "${cloudstack_ipaddress.public_ip.id}"
  depends_on = ["cloudstack_instance.master"]
  count = "${var.num_masters}"

  rule {
    source_cidr = "0.0.0.0/0"
    protocol = "tcp"
    ports = ["5050", "8080"]
  }
}

resource "cloudstack_instance" "master" {
    count = "${var.num_masters}"
    template = "${var.cs_image}"
    service_offering = "${var.master_instance_type}"
    keypair = "${var.cs_key_name}"
    network = "${cloudstack_network.network01.id}"
    name = "master-${count.index}"
    zone = "${var.cs_zone}"
    expunge = "true"
    ipaddress = "${format(\"172.16.0.%d\", var.master_instance_ip_start+count.index)}"

}


resource "cloudstack_ipaddress" "public_ip" {
    network = "${cloudstack_network.network01.id}"
    depends_on = ["cloudstack_instance.master"]
}

resource "cloudstack_port_forward" "master_ssh" {
  ipaddress = "${cloudstack_ipaddress.public_ip.id}"
  depends_on = ["cloudstack_instance.master"]
  count = "${var.num_masters}"

  forward {
    protocol = "tcp"
    private_port = "22"
    public_port = "${count.index+var.master_ssh_port_start}"
    virtual_machine = "${element(cloudstack_instance.master.*.name, count.index)}"
  }

  connection {
        host = "${cloudstack_ipaddress.public_ip.ipaddress}"
        user = "${var.cs_ssh_user}"
        key_file = "${var.cs_ssh_private_key_file}"
        port = "${count.index+var.master_ssh_port_start}"
  }
  provisioner "file" { 
     source = "${path.module}/scripts/"
     destination = "~/"
  }

  provisioner "remote-exec" {
      inline = [
          "sudo chmod a+x ~/configure_zk.py ~/configure_mesos.py",
          "sudo ./configure_zk.py -m -h ${join(\",\", cloudstack_instance.master.*.ipaddress)} -n ${count.index+1}",
          "sudo ./configure_mesos.py -m -h ${join(\",\", cloudstack_instance.master.*.ipaddress)} -i ${element(cloudstack_instance.master.*.ipaddress, count.index+1)}",
          "sudo stop mesos-slave",
          "sudo start mesos-master",
          "sudo restart zookeeper",
          "sudo start marathon",
          "echo \"Completed terraform provisioning\" > ~/install.log"
      ]
    }
}

resource "cloudstack_port_forward" "master_5050" {
  ipaddress = "${cloudstack_ipaddress.public_ip.id}"
  depends_on = ["cloudstack_instance.master"]

  forward {
    protocol = "tcp"
    private_port = "5050"
    public_port = "5050"
    virtual_machine = "${element(cloudstack_instance.master.*.name, 1)}"
  }
}

resource "cloudstack_port_forward" "master_8080" {
  ipaddress = "${cloudstack_ipaddress.public_ip.id}"
  depends_on = ["cloudstack_instance.master"]

  forward {
    protocol = "tcp"
    private_port = "8080"
    public_port = "8080"
    virtual_machine = "${element(cloudstack_instance.master.*.name, 1)}"
  }
}
