resource "aws_s3_bucket" "aaiTerraformStateS3Bucket" {
    bucket = "aai-terraform-state-do-not-delete-${var.env}"
    acl    = "private"
}

resource "aws_dynamodb_table" "aaiDynamodbTerraformLock" {
    name           = "aai-terraform-lock-${var.env}"
    hash_key       = "LockID"
    read_capacity  = 20
    write_capacity = 20

    attribute {
        name = "LockID"
        type = "S"
    }

    tags = {
        name = "AAI Terraform Lock Table ${var.env}"
    }
}
