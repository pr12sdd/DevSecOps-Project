resource "aws_dynamodb_table" "mytable" {
   name = "mydbtable"
   billing_mode = "PAY_PER_REQUEST"
   hash_key = "LockID"

   attribute {
     name = "LockID"
     type="S"
   }

   tags={
    Name="mydbtable"
   }
}