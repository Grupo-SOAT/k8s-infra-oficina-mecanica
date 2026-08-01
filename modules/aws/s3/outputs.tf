output "bucket_id" {

  description = "ID do bucket"

  value = aws_s3_bucket.this.id

}


output "bucket_arn" {

  description = "ARN do bucket"

  value = aws_s3_bucket.this.arn

}