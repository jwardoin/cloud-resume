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