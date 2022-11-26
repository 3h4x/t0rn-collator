data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "${path.root}/../infra/vpc/terraform.tfstate.d/t0rn-ec1-dev/terraform.tfstate"
  }
}

module "t0rn_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  name = "t0rn"

  context = module.this.context
}

data "template_file" "userdata" {
  template = "${file("userdata.sh.tpl")}"

  vars = {
    rococo_boot_node = var.rococo_boot_node
    t0rn_boot_node = var.t0rn_boot_node
    collator_name = var.collator_name
    image = var.collator_image
  }
}

module "autoscale_group" {
  source = "cloudposse/ec2-autoscale-group/aws"
  version = "v0.31.1"

  context = module.this.context

  image_id                    = "ami-076309742d466ad69" # Recent Amazon Linux 2, should be either from data source or variable
  instance_type               = var.instance_type
  security_group_ids          = [aws_security_group.this.id]
  subnet_ids                  = [for subnet_id in data.terraform_remote_state.vpc.outputs.private_subnet_ids : subnet_id]
  health_check_type           = "EC2"
  min_size                    = 1
  max_size                    = 1
  wait_for_capacity_timeout   = "5m"
  associate_public_ip_address = true

  user_data_base64 = base64encode(data.template_file.userdata.rendered)

  # All inputs to `block_device_mappings` have to be defined
  block_device_mappings = [
    {
      device_name  = "/dev/xvda"
      no_device    = "false"
      virtual_name = "root"
      ebs = {
        encrypted             = true
        volume_size           = var.volume_size
        delete_on_termination = true
        iops                  = null
        kms_key_id            = null
        snapshot_id           = null
        volume_type           = var.volume_type
      }
    }
  ]

  # Auto-scaling policies and CloudWatch metric alarms
  autoscaling_policies_enabled           = false
}

resource "aws_security_group" "this" {
  name        = "t0rn-collator"
  description = "t0rn-collator security group"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
