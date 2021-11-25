# Archive file
data "archive_file" "lambda-POST-presignedURL-zip" {
  type        = "zip"
  source_file = "${local.root_path}/../../../../../src/lambda_POST_presignedURL.py"
  output_path = "lambda-POST-presignedURL.zip"
}

data "archive_file" "lambda-modyf-image-zip" {
  type        = "zip"
  source_file = "${local.root_path}/../../../../../src/lambda_modyf_image.py"
  output_path = "lambda_modyf_image.zip"
}

data "archive_file" "lambda_to_dynamo_payload-zip" {
  type        = "zip"
  source_file = "${local.root_path}/../../../../../src/lambda_to_dynamo_payload.py"
  output_path = "lambda_to_dynamo_payload.zip"
}