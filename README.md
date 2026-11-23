# Project 2: S3 static website with Terraform

Terraform creates a dedicated S3 bucket in `ap-south-1`, uploads `index.htm`,
enables static website hosting, and allows anonymous `s3:GetObject` access to
that object only. The bucket remains private for listing and writes; public
ACLs remain blocked. Never upload secrets to the website object.

The S3 website endpoint uses **HTTP only**. It is not suitable for sensitive
data. S3 storage and requests can incur charges.

## Deploy

Prerequisites: Terraform, AWS CLI, Git, an authenticated AWS identity, and
approval to publish a public website in the account. Account-level S3 Block
Public Access and AWS Organizations policies can prevent public access. Do
not change these shared protections without administrator approval.

In PowerShell, from this repository:

```powershell
terraform init
$Account = aws sts get-caller-identity --query Account --output text
$Bucket = "project2-website-$Account-$([guid]::NewGuid().ToString('N').Substring(0,8))"
terraform plan -var "bucket_name=$Bucket" -out=tfplan
terraform apply tfplan
terraform output -raw website_url
```

Review the plan before applying. Open the output HTTP URL and capture the
website screenshot. The bucket name must be globally unique.

The configuration uses local Terraform state. Keep it private and retain it
for updates and cleanup; do not commit state, plan files, or credentials.

## Cleanup

Run `terraform destroy -var "bucket_name=$Bucket"` from the same directory
and review the plan. Terraform removes the managed website object and bucket.
Remove any other objects separately before destroying the bucket. Do not
delete the state file until cleanup is complete.
