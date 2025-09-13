# resource "aws_instance" "conn_test" {
#   ami           = "ami-0b09ffb6d8b58ca91"
#   instance_type = "t2.micro"

#   tags = {
#     Name = "Connection Test Instance"
#   }
# }

# Create an S3 bucket for static website hosting
resource "aws_s3_bucket" "staticWebsite" {
  bucket = "staticwebsite226753"

  tags = {
    Name        = "Static Website"
  }
}


# Upload a the HTML file to the S3 bucket for static website hosting
resource "aws_s3_object" "staticWebsite" {
  bucket = "staticwebsite226753"
  key    = "index.html"
  source = "index.html"
  content_type = "text/html"
  depends_on = [ aws_s3_bucket.staticWebsite ]
}

# Block all public access to the S3 bucket to enhance security for static website hosting
resource "aws_s3_bucket_public_access_block" "staticWebsite" {
  bucket = aws_s3_bucket.staticWebsite.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Set a bucket policy to allow only read access to the S3 bucket for static website hosting
resource "aws_s3_bucket_policy" "read_access" {
  bucket = aws_s3_bucket.staticWebsite.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = ["${aws_s3_bucket.staticWebsite.arn}/*",
                    "${aws_s3_bucket.staticWebsite.arn}"]
      }
    ]
  })
}

# Configure the S3 bucket for static website hosting for the uploaded HTML file
resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.staticWebsite.id

  index_document {
    suffix = "index.html"
  }

}
# Output the website URL for the S3 static website hosting to access the uploaded HTML file
output "website_url" {
  value = aws_s3_bucket.staticWebsite.website_endpoint
  description = "The URL to access the S3 static website"
}
