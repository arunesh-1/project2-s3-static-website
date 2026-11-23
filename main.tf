terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "website" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.htm"
  }
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.website.id
  key          = "index.htm"
  source       = "${path.module}/index.htm"
  etag         = filemd5("${path.module}/index.htm")
  content_type = "text/html; charset=utf-8"
}

data "aws_iam_policy_document" "website" {
  statement {
    sid     = "PublicReadWebsiteIndex"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.website.arn}/index.htm"
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.website.json

  depends_on = [aws_s3_bucket_public_access_block.website]
}

output "website_url" {
  description = "Public HTTP website endpoint."
  value       = "http://${aws_s3_bucket_website_configuration.website.website_endpoint}/"
}
