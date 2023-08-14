####################
# S3 Operations
####################

# Generate Random Tag

resource "random_pet" "random_prefix" {
  prefix = var.env_name
  length = 1
}

# Create S3  Buckets

resource "aws_s3_bucket" "autoscale_layer_bucket" {
  bucket = "${random_pet.random_prefix.id}-autoscale-layer-bucket"
}

resource "aws_s3_bucket" "autoscale_manager_bucket" {
  bucket = "${random_pet.random_prefix.id}-autoscale-manager-bucket"
}

resource "aws_s3_bucket" "lifecycle_ftdv_bucket" {
  bucket = "${random_pet.random_prefix.id}-lifecycle-ftdv-bucket"
}

resource "aws_s3_bucket" "custom_metric_fmc_bucket" {
  bucket = "${random_pet.random_prefix.id}-custom-metric-fmc-bucket"
}

# Add S3 Objects

resource "aws_s3_object" "lambda_layer_files" {
  bucket = aws_s3_bucket.autoscale_layer_bucket.id

  key    = "autoscale_layer.zip"
  source = "${path.module}/target/autoscale_layer.zip"

  etag = filemd5("${path.module}/target/autoscale_layer.zip")
}

resource "aws_s3_object" "autoscale_manager_files" {
  bucket = aws_s3_bucket.autoscale_manager_bucket.id

  key    = "autoscale_manager.zip"
  source = "${path.module}/target/autoscale_manager.zip"

  etag = filemd5("${path.module}/target/autoscale_manager.zip")
}

resource "aws_s3_object" "custom_metric_fmc_files" {
  bucket = aws_s3_bucket.custom_metric_fmc_bucket.id

  key    = "custom_metric_fmc.zip"
  source = "${path.module}/target/custom_metric_fmc.zip"

  etag = filemd5("${path.module}/target/custom_metric_fmc.zip")
}

resource "aws_s3_object" "lifecycle_ftdv_files" {
  bucket = aws_s3_bucket.lifecycle_ftdv_bucket.id

  key    = "lifecycle_ftdv.zip"
  source = "${path.module}/target/lifecycle_ftdv.zip"

  etag = filemd5("${path.module}/target/lifecycle_ftdv.zip")
}