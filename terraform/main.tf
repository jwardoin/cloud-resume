terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.68"
    }
  }
  cloud {
    organization = "JordanArdoin"
    workspaces {
      name = "CRC-Terraform-Automate"
    }
  }
}

provider "aws" {
  shared_credentials_file = "~/.aws/credentials"
  profile = "default"
  region  = "us-east-1"

}

# Data

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# data "aws_s3_bucket_object" "package" { # TODO: Integrate Hashing for Lambda Code
#   bucket = "crcterraformtestjwa"
#   key    = "lambda.zip"
}


# DyanmoDB Table

resource "aws_dynamodb_table" "crc_ddb" {
  name         = "CRC_DB"
  hash_key     = "WebsiteVisits"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "WebsiteVisits"
    type = "S"
  }
}

# Permissions

resource "aws_iam_role" "CRC_Lambda_IAM" {
  name               = "CRC_Lambda_Role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "lambda_ddb" {
  name = "lambda_ddb_update_get"
  role = aws_iam_role.CRC_Lambda_IAM.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "",
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
        ]
        Resource = "arn:aws:dynamodb:us-east-1:*:table/CRC_DB"
      },
    ]
  })
}

resource "aws_lambda_permission" "allow_api" {
  statement_id  = "AllowAPIgatewayInvokation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.crc_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.CRC_API.id}/*/*/*"
}

# Lambda Function

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

# API

resource "aws_api_gateway_rest_api" "CRC_API" {
  name = "CRC_API"
}

resource "aws_api_gateway_resource" "CRC_API_resource" {
  rest_api_id = aws_api_gateway_rest_api.CRC_API.id
  parent_id   = aws_api_gateway_rest_api.CRC_API.root_resource_id
  path_part   = "WebsiteVisits"
}

resource "aws_api_gateway_method" "get" {
  authorization    = "NONE"
  http_method      = "GET"
  resource_id      = aws_api_gateway_resource.CRC_API_resource.id
  rest_api_id      = aws_api_gateway_rest_api.CRC_API.id
  api_key_required = false
}

resource "aws_api_gateway_method_response" "methodresponse" {
  rest_api_id = aws_api_gateway_rest_api.CRC_API.id
  resource_id = aws_api_gateway_resource.CRC_API_resource.id
  http_method = aws_api_gateway_method.get.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
}

resource "aws_api_gateway_integration" "CRC_API_int" {
  rest_api_id             = aws_api_gateway_rest_api.CRC_API.id
  resource_id             = aws_api_gateway_resource.CRC_API_resource.id
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.crc_lambda.invoke_arn

}

resource "aws_api_gateway_integration_response" "int_response" {
  rest_api_id = aws_api_gateway_rest_api.CRC_API.id
  resource_id = aws_api_gateway_resource.CRC_API_resource.id
  http_method = aws_api_gateway_method.get.http_method
  status_code = aws_api_gateway_method_response.methodresponse.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods"     = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"      = "'*'",
    "method.response.header.Access-Control-Allow-Credentials" = "'true'"
  }
  depends_on = [
    aws_api_gateway_integration.CRC_API_int
  ]
}

resource "aws_api_gateway_deployment" "CRC_API_deploy" {
  rest_api_id = aws_api_gateway_rest_api.CRC_API.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.CRC_API.body))
  }

  depends_on = [aws_api_gateway_integration.CRC_API_int]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.CRC_API_deploy.id
  rest_api_id   = aws_api_gateway_rest_api.CRC_API.id
  stage_name    = "prod"
}

# CORS Enabled API

resource "aws_api_gateway_method" "cors_method" {
  rest_api_id   = aws_api_gateway_rest_api.CRC_API.id
  resource_id   = aws_api_gateway_resource.CRC_API_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors_int" {
  rest_api_id      = aws_api_gateway_rest_api.CRC_API.id
  resource_id      = aws_api_gateway_resource.CRC_API_resource.id
  http_method      = aws_api_gateway_method.cors_method.http_method
  content_handling = "CONVERT_TO_TEXT"

  type = "MOCK"

  request_templates = {
    "application/json" = "{ \"statusCode\": 200 }"
  }
}

resource "aws_api_gateway_integration_response" "cors_int_response" {
  rest_api_id = aws_api_gateway_rest_api.CRC_API.id
  resource_id = aws_api_gateway_resource.CRC_API_resource.id
  http_method = aws_api_gateway_method.cors_method.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [
    aws_api_gateway_integration.cors_int,
    aws_api_gateway_method_response.cors_method_response,
  ]

}

resource "aws_api_gateway_method_response" "cors_method_response" {
  rest_api_id = aws_api_gateway_rest_api.CRC_API.id
  resource_id = aws_api_gateway_resource.CRC_API_resource.id
  http_method = aws_api_gateway_method.cors_method.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true,
    "method.response.header.Access-Control-Allow-Credentials" = true

  }

  response_models = {
    "application/json" = "Empty"
  }
  depends_on = [
    aws_api_gateway_method.cors_method,
  ]
}

