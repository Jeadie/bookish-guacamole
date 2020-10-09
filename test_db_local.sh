echo "Running Dynamo DB locally"
docker run -p 8000:8000 amazon/dynamodb-local > /dev/null & 

echo "Creating messsage_recv table"
aws dynamodb create-table \
  --table-name message_recv \
  --attribute-definitions \
    AttributeName=moduleId,AttributeType=S \
    AttributeName=timestamp,AttributeType=N \
  --key-schema \
    AttributeName=moduleId,KeyType=HASH \
    AttributeName=timestamp,KeyType=RANGE \
  --billing-mode PAY_PER_REQUEST \
  --endpoint-url http://localhost:8000

echo "Create weekly_diagnostic table"
aws dynamodb create-table \
  --table-name weekly_diagnostic \
  --attribute-definitions \
    AttributeName=moduleId,AttributeType=S \
    AttributeName=timestamp,AttributeType=N \
  --key-schema \
    AttributeName=moduleId,KeyType=HASH \
    AttributeName=timestamp,KeyType=RANGE \
  --billing-mode PAY_PER_REQUEST \
  --endpoint-url http://localhost:8000

echo "Adding items to tables..."

aws dynamodb put-item \
  --table-name message_recv \
  --item ' {
    "moduleId": {"S": "moduleID1234"},
    "timestamp": {"N": "1234567890"}
  }' \
  --endpoint-url http://localhost:8000

aws dynamodb put-item \
  --table-name weekly_diagnostic \
  --item ' {
    "moduleId": {"S": "moduleID1234"},
    "timestamp": {"N": "9876543210"},
    "attempts": {"N": "42"}
  }' \
  --endpoint-url http://localhost:8000

echo "Retrieving new Items"
aws dynamodb query \
  --table-name message_recv \
  --key-condition-expression "moduleId = :moduleid" \
  --expression-attribute-values ' {
    ":moduleid": {"S": "moduleID1234"}
  }' \
  --endpoint-url http://localhost:8000

aws dynamodb query \
  --table-name weekly_diagnostic \
  --key-condition-expression "moduleId = :moduleid" \
  --expression-attribute-values ' {
    ":moduleid": {"S": "moduleID1234"}
  }' \
  --endpoint-url http://localhost:8000

