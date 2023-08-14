##################
# Launch Template
##################

# FTD Data

data "aws_ami" "ftdv" {
  most_recent = true
  owners      = ["679593333241"]
  filter {
    name   = "name"
    values = ["ftdv-7.3*"]
  }
  filter {
    name   = "product-code"
    values = ["a8sxy6easi2zumgtyr564z6y7"]
  }
}

# Launch Template

resource "aws_launch_template" "ftd_launch_template" {
  name                                 = "${var.env_name}-launch-template"
  image_id                             = data.aws_ami.ftdv.image_id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = "c3.xlarge"
  key_name                             = aws_key_pair.public_key.key_name
  #security_group_names = [aws_security_group.allow_all.name]
  network_interfaces {
    description     = "ftd_mgmt_if"
    subnet_id       = aws_subnet.mgmt_subnet.id
    associate_public_ip_address = true
    delete_on_termination = true
    device_index                = 0
  }
  user_data = base64encode("{ \"AdminPassword\": \"${var.ftd_pass}\"}")
}
