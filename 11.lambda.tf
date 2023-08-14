####################
# Lambda Functions
####################

# EC2 VPC Endpoint

resource "aws_vpc_endpoint" "ec2_ep" {
  vpc_id            = aws_vpc.srvc_vpc.id
  service_name      = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type = "Interface"
  subnet_ids = [aws_subnet.lambda_subnet.id]
  security_group_ids = [
    aws_security_group.allow_all.id
  ]
  tags = {
    Name = "${var.env_name}-EC2-VPC-Endpoint"
  }
  private_dns_enabled = true
}

# Autoscaling VPC Endpoint

resource "aws_vpc_endpoint" "autoscale_ep" {
  vpc_id            = aws_vpc.srvc_vpc.id
  service_name      = "com.amazonaws.${var.region}.autoscaling"
  vpc_endpoint_type = "Interface"
  subnet_ids = [aws_subnet.lambda_subnet.id]
  security_group_ids = [
    aws_security_group.allow_all.id
  ]
  tags = {
    Name = "${var.env_name}-AutoScaling-VPC-Endpoint"
  }
  private_dns_enabled = true
}

# ELB VPC Endpoint

resource "aws_vpc_endpoint" "elb_ep" {
  vpc_id            = aws_vpc.srvc_vpc.id
  service_name      = "com.amazonaws.${var.region}.elasticloadbalancing"
  vpc_endpoint_type = "Interface"
  subnet_ids = [aws_subnet.lambda_subnet.id]
  security_group_ids = [
    aws_security_group.allow_all.id
  ]
  tags = {
    Name = "${var.env_name}-ELB-VPC-Endpoint"
  }
  private_dns_enabled = true
}

# SNS VPC Endpoint

resource "aws_vpc_endpoint" "sns_ep" {
  vpc_id            = aws_vpc.srvc_vpc.id
  service_name      = "com.amazonaws.${var.region}.sns"
  vpc_endpoint_type = "Interface"
  subnet_ids = [aws_subnet.lambda_subnet.id]
  security_group_ids = [
    aws_security_group.allow_all.id
  ]
  tags = {
    Name = "${var.env_name}-SNS-VPC-Endpoint"
  }
  private_dns_enabled = true
}

# Events VPC Endpoint

resource "aws_vpc_endpoint" "events_ep" {
  vpc_id            = aws_vpc.srvc_vpc.id
  service_name      = "com.amazonaws.${var.region}.events"
  vpc_endpoint_type = "Interface"
  subnet_ids = [aws_subnet.lambda_subnet.id]
  security_group_ids = [
    aws_security_group.allow_all.id
  ]
  tags = {
    Name = "${var.env_name}-Events-VPC-Endpoint"
  }
  private_dns_enabled = true
}

# Lambda Layer

resource "aws_lambda_layer_version" "lambda_layer" {
  layer_name          = "${var.env_name}-layer-s3"
  description         = "My amazing lambda layer (deployed from S3)"
  compatible_runtimes = ["python3.9", "python3.10"]
  s3_bucket           = aws_s3_bucket.autoscale_layer_bucket.id
  s3_key              = aws_s3_object.lambda_layer_files.key
}

# Autoscale Manager

resource "aws_lambda_function" "autoscale_manager" {
  function_name = "${var.env_name}-AutoscaleManager"
  description   = "AutoscaleManager Lambda is responsible to configure NGFWv"
  memory_size   = 128
  timeout       = 900
  vpc_config {
    security_group_ids = [aws_security_group.allow_all.id]
    subnet_ids         = [aws_subnet.lambda_subnet.id]
  }
  layers = [aws_lambda_layer_version.lambda_layer.arn]
  environment {
    variables = {
      DEBUG_LOGS : "enable"
      GENEVE_SUPPORT : "enable"
      ASG_NAME : aws_autoscaling_group.ftdv-asg.name
      FMC_DEVICE_GRP : var.fmc_device_grp_name
      FMC_PERFORMANCE_TIER : var.fmc_performance_license_tier
      FMC_SERVER : local.fmc_mgmt_ip
      FMC_USERNAME : var.fmc_username
      FMC_PASSWORD : var.fmc_password
      CDFMC: !var.create_fmcv
      CDO_TOKEN: var.cdo_token
      NO_OF_AZs : 1
      FTD_LICENSE_TYPE : var.license_type
      LB_ARN_OUTSIDE : aws_lb.gwlb.arn
      FTD_PASSWORD : var.ftd_pass
      TG_HEALTH_PORT : var.tg_health_port
      AS_MANAGER_TOPIC : aws_sns_topic.as_manager_topic.id
      USER_NOTIFY_TOPIC_ARN : aws_sns_topic.user_notify_topic.id
      A_CRON_JOB_NAME : join("-", [aws_autoscaling_group.ftdv-asg.name, "health-doc-cron"] )
    }
  }

  s3_bucket = aws_s3_bucket.autoscale_manager_bucket.id
  s3_key    = aws_s3_object.autoscale_manager_files.key

  runtime = "python3.9"
  handler = "manager.lambda_handler"

  role = aws_iam_role.lambda_role.arn
}

# Custom Metric FMC

resource "aws_lambda_function" "custom_metric_fmc" {
  function_name = "${var.env_name}-CustomMetricFMC"
  vpc_config {
    security_group_ids = [aws_security_group.allow_all.id]
    subnet_ids         = [aws_subnet.lambda_subnet.id]
  }
  s3_bucket = aws_s3_bucket.custom_metric_fmc_bucket.id
  s3_key    = aws_s3_object.custom_metric_fmc_files.key

  runtime = "python3.9"
  handler = "custom_metric_fmc.lambda_handler"
  layers  = [aws_lambda_layer_version.lambda_layer.arn]

  role = aws_iam_role.lambda_role.arn
  timeout       = 900
}

# Lifecycle FMC

resource "aws_lambda_function" "lifecycle_ftdv" {
  function_name = "${var.env_name}-LifecycleFTDv"
  vpc_config {
    security_group_ids = [aws_security_group.allow_all.id]
    subnet_ids         = [aws_subnet.lambda_subnet.id]
  }
  s3_bucket = aws_s3_bucket.lifecycle_ftdv_bucket.id
  s3_key    = aws_s3_object.lifecycle_ftdv_files.key
  timeout       = 900
  runtime = "python3.9"
  handler = "lifecycle_ftdv.lambda_handler"
  layers  = [aws_lambda_layer_version.lambda_layer.arn]
  reserved_concurrent_executions = 10
  environment {
    variables = {
      DEBUG_LOGS : "enable"
      FMC_PERFORMANCE_TIER : var.fmc_performance_license_tier
      LB_DEREGISTRATION_DELAY : 180
      INSIDE_SUBNET : aws_subnet.data_subnet.id
      OUTSIDE_SUBNET : aws_subnet.ccl_subnet.id
      FMC_DEVICE_GRP : var.fmc_device_grp_name
      FTD_LICENSE_TYPE : var.license_type
      NO_OF_AZs : 1
      ASG_NAME : aws_autoscaling_group.ftdv-asg.name
      USER_NOTIFY_TOPIC_ARN : aws_sns_topic.user_notify_topic.id
      SECURITY_GRP_2 : aws_security_group.sg_inbound.id
      LB_ARN_OUTSIDE : aws_lb.gwlb.id
      SECURITY_GRP_3 : aws_security_group.sg_outbound.id
      GENEVE_SUPPORT : "enable"
      CONFIGURE_ASAV_TOPIC_ARN : aws_sns_topic.ftd-asg_sns_topic.arn
    }
  }
  role = aws_iam_role.lambda_role.arn
}





