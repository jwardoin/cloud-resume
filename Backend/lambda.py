import json
import boto3

client = boto3.client('dynamodb')

def lambda_handler(event, context):
    
    # Increments the 'amount' of Website Visits by 1 each time code is run
    
    response = client.update_item(
        TableName='CRC_DB',
        Key={'WebsiteVisits': {'S': 'WebsiteVisits'}},
        UpdateExpression="ADD #amount :increment",
        ExpressionAttributeNames={'#amount': 'amount'},
        ExpressionAttributeValues={':increment': {'N': "1"}}              
    )
    
     # Gets current value of 'amount'
    
    responsetwo = client.get_item(
        TableName='CRC_DB', 
        Key={'WebsiteVisits': {'S': 'WebsiteVisits'}},
        ProjectionExpression='amount')
    
    # Returns current 'amount' to API
    
    return {
        'isBase64Encoded': False,
        'statusCode': 200,
        'body': json.dumps(responsetwo['Item']["amount"]["N"]),
        'headers': {
            'Access-Control-Allow-Headers': 'application/json, Content-Type',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
        }
        }
