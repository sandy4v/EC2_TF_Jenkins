terraform {
  backend "s3" {

    bucket = "my-tf-statefile-bckt"
    key    = "devops/jenkins/terraform.tfstate"
    region = "us-east-2"
    # Replace this with your DynamoDB table name!
    # dynamodb_table = "db-dynamo-tf-state"
    # encrypt        = true
  
  }
}