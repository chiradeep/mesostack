module "mesostack" {
    source = "./cloudstack"

    # CS API URL
    cs_api_url = "http://10.81.29.35:8080/client/api"

    # CS access key
    cs_api_key = "bZJRKacZsx3G8V1jjuHakMMKmO2Ja3ScNH8dWA0L2Xi3TVqw4mHnLqcz39kuHoBfG3jwty3OCRi0sx07qrPT8w"

    # CS secret key
    cs_secret_key = "RrcPRvetaMx48m6K6fTjq-iM3E5pV_L-_MsbO_K0ih3W3UPOAADoRNrRWwaPBP_PSsfqXjUwVzH4ze3QbgQLBQ"

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


