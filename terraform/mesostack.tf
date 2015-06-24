module "mesostack" {
    source = "./cloudstack"

    # CS API URL
    cs_api_url = "http://10.10.122.33:8080/client/api"

    # CS access key
    cs_api_key = "qSy40uxUscFj63oT6QpKWJQitLuIcgbhZBhVoNAq129x7lLZdEK3DrE5BdUlJl-3NuO0ZJu6Rs64wh5qTngX6A"

    # CS secret key
    cs_secret_key = "dKflJiNEx_UruBjoiqtHmhakAYY6mwgM4INnAzKUln4LKyOClsf72I0FeRw5ou-2aGPz7eTiA_hVQFzc0PfBbQ"

    # The SSH key name to use for the instances
    cs_key_name = "ubuntu"

    # Path to the SSH private key file
    cs_ssh_private_key_file = "./ubuntu.pem"

    # cloudstack zone name
    cs_zone = "zone001"

    # The number of master VMs to launch
    num_masters = "3"

    # The number of slave VMs to launch
    num_slaves = "3"

}

output "public_ip" {
    value = "${module.mesostack.public_ip}"
}


