variable "do_token" {}

# these are optional, maybe there is a better way?
# https://github.com/hashicorp/terraform/issues/5471
variable "public_key_path" { default = "" }
variable "public_key_fingerprint" { default = "" }
variable "private_key_path" { default = "" }

variable "nodes_count" {
  default = 2
}

provider "digitalocean" {
  token = "${var.do_token}"
  version = "~> 0.1"
}

resource "digitalocean_tag" "awesome" {
  name = "awesome"
}

resource "digitalocean_droplet" "example" {
  count = "${var.nodes_count}"

  region = "fra1"
  size = "s-1vcpu-1gb"
  image = "ubuntu-18-04-x64"
  name = "libcluster-example-${count.index}"
  private_networking = true

  ssh_keys = ["${var.public_key_fingerprint}"]

  tags = ["${digitalocean_tag.awesome.id}"]

  connection {
    type = "ssh"
    user = "root"
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "file" {
    source = "../export"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    script = "../bin/setup_vm"
  }
}

output "public_ipv4_addresses" {
  value = "${digitalocean_droplet.example.*.ipv4_address}"
}
