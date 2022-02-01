data "aws_s3_bucket_object" "lambda" {
  bucket = "crcterraformtestjwa"
  key    = "lambda.zip"
}

resource "aws_lambda_function" "crc_lambda" {
  function_name = "CRC_lambda"
  s3_bucket     = "crcterraformtestjwa"
  s3_key        = "lambda.zip"
  role          = aws_iam_role.CRC_Lambda_IAM.arn
  handler       = "lambda.lambda_handler"
  runtime       = "python3.9"
#   source_code_hash = data.aws_s3_bucket_object.package.metadata.Hash # TODO: Integrate Hashing for Lambda Code
}