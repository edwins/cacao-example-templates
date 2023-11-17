terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack" # "terraform.cyverse.org/cyverse/openstack"
    }
  }
}

provider "openstack" {
  tenant_name = var.project
  region = var.region
}

resource "openstack_compute_instance_v2" "os_instances" {
  name = var.instance_name
  image_name = var.image
  flavor_name = var.flavor
  key_pair = var.keypair
  security_groups = ["cacao-default"]
  power_state = var.power_state
  user_data = var.user_data

  block_device {
    uuid = local.image_uuid
    source_type = "image"
    destination_type = "volume"
    boot_index = 0
    delete_on_termination = true
    volume_size = var.root_storage_size
  }

  network {
    name = "auto_allocated_network"
  }
}

data "openstack_networking_network_v2" "ext_network" {
  # make the assumption that there is only 1 external network per region, this will fail if otherwise
  region = var.region
  external = true
}

resource "openstack_networking_floatingip_v2" "os_floatingips" {
  count = var.power_state == "active" ? 1 : 0
  pool = data.openstack_networking_network_v2.ext_network.name
  description = "floating ip for ${var.instance_name}"
}

resource "openstack_compute_floatingip_associate_v2" "os_floatingips_associate" {
  count = var.power_state == "active" ? 1 : 0
  floating_ip = openstack_networking_floatingip_v2.os_floatingips[0].address
  instance_id = openstack_compute_instance_v2.os_instances.id
}

locals {
  split_username = split("@", var.username)
  real_username = local.split_username[0]

  # for jetstream2, gpu flavors begin with g3
  enable_gpu = tostring(startswith(var.flavor, "g3"))
}

resource "null_resource" "provision" {
  depends_on = [openstack_networking_floatingip_v2.os_floatingips[0],openstack_compute_instance_v2.os_instances]

  connection {
    type = "ssh"
    agent = true
    user = local.real_username
    host = openstack_networking_floatingip_v2.os_floatingips[0].address
  }

  provisioner "remote-exec" {
    inline = [<<-EOF
        #!/bin/bash
        sudo pip3 install --upgrade -I pip
        sudo pip3 install "fschat[model_worker,webui]"
        sudo pip3 install --upgrade jinja2

        # creating a directory for logs
        sudo mkdir /var/log/fastchat
        sudo chown ${local.real_username} /var/log/fastchat

        # running the controller in the background
        nohup python3 -m fastchat.serve.controller >/var/log/fastchat/controller.log 2>&1 &

        # running the workers in the background
        if [ "${local.enable_gpu}" == "true" ]; then
            nohup python3 -m fastchat.serve.model_worker --model-path lmsys/vicuna-7b-v1.5 >/var/log/fastchat/worker.log 2>&1 &
        else
            nohup python3 -m fastchat.serve.model_worker --model-path lmsys/vicuna-7b-v1.5 --device cpu >/var/log/fastchat/worker.log 2>&1 &
        fi

        # wait until workers are ready
        output=$(python3 -m fastchat.serve.test_message --model-name vicuna-7b-v1.5)
        ret=$?
        while [ $ret -ne 0 ] || [[ "$output" =~ "No available workers for" ]]; do
            echo "waiting for workers to be ready"
            sleep 5
            output=$(python3 -m fastchat.serve.test_message --model-name vicuna-7b-v1.5)
            ret=$?
        done
        echo "done waiting for workers to be ready"
        sleep 5

        # running gradio web in the background
        nohup python3 -m fastchat.serve.gradio_web_server --port 8080 >/var/log/fastchat/web.log 2>&1 &

        sleep 1
        EOF
    ]
  }
}

data "openstack_images_image_v2" "instance_image" {
  name = var.image
  most_recent = true
}

locals {
  image_uuid = var.image == "" ? var.image : data.openstack_images_image_v2.instance_image.id
}
output "ip" {
  value = openstack_networking_floatingip_v2.os_floatingips[0].address
}
