# resource "aws_instance" "conn_test" {
#   ami           = "ami-0b09ffb6d8b58ca91"
#   instance_type = "t2.micro"

#   tags = {
#     Name = "Connection Test Instance"
#   }
# }

# Create an S3 bucket for static website hosting
resource "aws_s3_bucket" "static_website" {
  bucket = "Static-Website-Bucket-23456"

  tags = {
    Name        = "Static Website"
  }
}


# Upload a the HTML file to the S3 bucket for static website hosting
resource "aws_s3_object" "website" {
  bucket = "Static-Website-Bucket-23456"
  key    = "website.html"
  source = "Employee-Chart.html"
}

# Block all public access to the S3 bucket to enhance security for static website hosting
resource "aws_s3_bucket_public_access_block" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Set a bucket policy to allow only read access to the S3 bucket for static website hosting
resource "aws_s3_bucket_policy" "read_access" {
  bucket = aws_s3_bucket.static_website.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.static_website.arn}/*"
      }
    ]
  })
}

# Configure the S3 bucket for static website hosting for the uploaded HTML file
resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.static_website.id

  index_document {
    suffix = "website.html"
  }

}
# Output the website URL for the S3 static website hosting to access the uploaded HTML file
output "website_url" {
  value = aws_s3_bucket.static_website.website_endpoint
  description = "The URL to access the S3 static website"
}
