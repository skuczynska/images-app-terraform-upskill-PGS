resource "aws_lambda_function" "resize" {
  filename         = "lambda_modyf_image.zip"
  function_name    = "${var.owner}-lambda-resize"
  role             = aws_iam_role.skuczynska-role-rezise.arn
  handler          = "lambda_modyf_image.lambda_handler"
  source_code_hash = data.archive_file.lambda-modyf-image-zip.output_base64sha256

  layers = [aws_lambda_layer_version.pillow_layer.arn]

  runtime = "python3.8"
}

resource "aws_lambda_layer_version" "pillow_layer" {
  filename   = "pillow.zip"
  layer_name = "${var.owner}-pillow_layer"

  compatible_runtimes = ["python3.8"]

}
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.resize.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket-resized.arn
}