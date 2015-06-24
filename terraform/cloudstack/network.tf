resource "cloudstack_network" "network01" {
    name = "${var.cs_network_name}"
    display_text = "${var.cs_network_name}"
    cidr = "${var.cs_nw_cidr_block}"
    network_offering = "DefaultIsolatedNetworkOfferingWithSourceNatService"
    zone = "${var.cs_zone}"
}

