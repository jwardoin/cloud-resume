resource "aws_dynamodb_table" "crc_ddb" {
  name         = "CRC_DB"
  hash_key     = "WebsiteVisits"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "WebsiteVisits"
    type = "S"
  }
}
