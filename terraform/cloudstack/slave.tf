

resource "cloudstack_firewall" "slave_ssh" {
  ipaddress = "${cloudstack_ipaddress.public_ip.id}"
  depends_on = ["cloudstack_instance.slave"]
  count = "${var.num_slaves}"

  rule {
    source_cidr = "0.0.0.0/0"
    protocol = "tcp"
    ports = ["${count.index+var.slave_ssh_port_start}"]
  }
}


resource "cloudstack_instance" "slave" {
    depends_on = ["cloudstack_instance.master"]
    count = "${var.num_slaves}"
    template = "${var.cs_image}"
    service_offering = "${var.slave_instance_type}"
    keypair = "${var.cs_key_name}"
    network = "${cloudstack_network.network01.id}"
    name = "slave-${count.index}"
    zone = "${var.cs_zone}"
    expunge = "true"

}


resource "cloudstack_port_forward" "slave_ssh" {
  ipaddress = "${cloudstack_ipaddress.public_ip.id}"
  depends_on = ["cloudstack_instance.slave"]
  count = "${var.num_slaves}"

  forward {
    protocol = "tcp"
    private_port = "22"
    public_port = "${count.index+var.slave_ssh_port_start}"
    virtual_machine = "${element(cloudstack_instance.slave.*.name, count.index)}"
  }

  connection {
        host = "${cloudstack_ipaddress.public_ip.ipaddress}"
        user = "${var.cs_ssh_user}"
        key_file = "${var.cs_ssh_private_key_file}"
        port = "${count.index+var.slave_ssh_port_start}"
  }
  provisioner "file" { 
     source = "${path.module}/scripts/"
     destination = "~/"
  }

  provisioner "remote-exec" {
      inline = [
          "sudo chmod a+x ~/configure_zk.py ~/configure_mesos.py",
          "sudo ./configure_zk.py  -h ${join(\",\", cloudstack_instance.master.*.ipaddress)} -n ${count.index+1}",
          "sudo ./configure_mesos.py  -i ${self.ipaddress}",
          "sudo ./configure_mesos.py -i ${element(cloudstack_instance.slave.*.ipaddress, count.index+1)}",
          "sudo stop mesos-master",
          "sudo start mesos-slave",
          "echo \"Completed terraform slave provisioning\" > ~/install.log"
      ]
    }
}
