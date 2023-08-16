##################
# Interfaces
##################
/*
# FTD Management interface
resource "aws_network_interface" "ftd_management" {
  count = var.auto_scale_group_size
  description     = "ftd_mgmt_if"
  subnet_id       = aws_subnet.mgmt_subnet.id
  security_groups = [aws_security_group.allow_all.id]
  tags = {
    Name = "${var.env_name} Service FTD Mgmt"
  }
}

# FTD Diagnostic interface
resource "aws_network_interface" "ftd_diagnostic" {
  count = var.auto_scale_group_size
  description     = "ftd_diag_if"
  subnet_id       = aws_subnet.mgmt_subnet.id
  security_groups = [aws_security_group.allow_all.id]
  tags = {
    Name = "${var.env_name} Service FTD Diag"
  }
}

# FTD Data interface
resource "aws_network_interface" "ftd_data" {
  count = var.auto_scale_group_size
  description       = "ftd_data_if"
  subnet_id         = aws_subnet.data_subnet.id
  security_groups   = [aws_security_group.allow_all.id]
  source_dest_check = false
  tags = {
    Name = "${var.env_name} Service FTD Data"
  }
}

# CCL interfaces
resource "aws_network_interface" "ftd_ccl" {
  count = var.auto_scale_group_size
  description       = "ftd_ccl_if"
  subnet_id         = aws_subnet.ccl_subnet.id
  security_groups   = [aws_security_group.allow_all.id]
  source_dest_check = false
  tags = {
    Name = "${var.env_name} Service FTD CCL"
  }
}
*/

# FMCv Mgmt Interface
resource "aws_network_interface" "fmc_management" {
  depends_on      = [aws_subnet.mgmt_subnet]
  count           = var.create_fmcv ? 1 : 0
  description     = "fmc-mgmt"
  subnet_id       = aws_subnet.mgmt_subnet.id
  private_ips     = [var.fmc_mgmt_private_ip]
  security_groups = [aws_security_group.allow_all.id]
  tags = {
    Name = "${var.env_name} FMCv Mgmt"
  }
}

# FMC Data Interface
resource "aws_network_interface" "fmc_data" {
  depends_on      = [aws_subnet.aws_subnet.mgmt_subnet]
  count           = var.create_fmcv ? 1 : 0
  description     = "fmc_data"
  subnet_id       = aws_subnet.mgmt_subnet.id
  private_ips     = [var.fmc_data_private_ip]
  security_groups = [aws_security_group.allow_all.id]
  tags = {
    Name = "${var.env_name} FMCv Data"
  }
}