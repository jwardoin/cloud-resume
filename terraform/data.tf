data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# data "aws_s3_bucket_object" "package" { # TODO: Integrate Hashing for Lambda Code
#   bucket = "crcterraformtestjwa"
#   key    = "lambda.zip"
}
