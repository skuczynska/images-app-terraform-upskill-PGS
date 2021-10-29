# Archive file
data "archive_file" "lambda-POST-presignedURL-zip" {
  type        = "zip"
  source_file = "src/lambda_POST_presignedURL.py"
  output_path = "lambda-POST-presignedURL.zip"
}