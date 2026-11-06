data "aws_caller_identity" "current" {}

locals {
  repo = "${var.github_owner}/${var.github_repo}"
}

# ---------------------------------------------------------------
# 1. S3 bucket for pg-lab's state
# ---------------------------------------------------------------

resource "aws_s3_bucket" "state" {
  # Bucket names are global across all of AWS; the account ID makes it unique
  bucket = "pg-lab-tfstate-${data.aws_caller_identity.current.account_id}"

  lifecycle {
    prevent_destroy = true
  }
}

# Keeps every old version of the state file, so a bad apply can be rolled back
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ---------------------------------------------------------------
# 2. Trust GitHub as an identity provider (OIDC)
# ---------------------------------------------------------------

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  # AWS no longer checks these for GitHub, but some provider versions require a value
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
  ]
}

# ---------------------------------------------------------------
# 3. Plan role: read-only, used by pull requests
# ---------------------------------------------------------------

resource "aws_iam_role" "plan" {
  name = "pg-lab-github-plan"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          # Only pull requests in your repo can use this role
          "token.actions.githubusercontent.com:sub" = "repo:${local.repo}:pull_request"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "plan_readonly" {
  role       = aws_iam_role.plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# Plan reads the state and briefly writes a lock file next to it
resource "aws_iam_role_policy" "plan_state" {
  name = "state-access"
  role = aws_iam_role.plan.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = aws_s3_bucket.state.arn
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.state.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:DeleteObject"]
        Resource = "${aws_s3_bucket.state.arn}/*.tflock"
      },
    ]
  })
}

# ---------------------------------------------------------------
# 4. Apply role: can change things, only from the main branch
# ---------------------------------------------------------------

resource "aws_iam_role" "apply" {
  name = "pg-lab-github-apply"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          # Only runs on the main branch can use this role
          "token.actions.githubusercontent.com:sub" = "repo:${local.repo}:ref:refs/heads/main"
        }
      }
    }]
  })
}

# Lab shortcut. At work this would be a policy limited to the services the code manages.
resource "aws_iam_role_policy_attachment" "apply_admin" {
  role       = aws_iam_role.apply.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
