data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy" "demo_user_permissions_boundary" {
  name = "DemoUser"
}

data "aws_iam_policy" "security_compute_access" {
  name = "SecurityComputeAccess"
}

data "aws_iam_policy_document" "client_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

locals {
  my_email = split("/", data.aws_caller_identity.current.arn)[2]
}

# EC2 IAM role for authenticating with Vault
resource "aws_iam_role" "vault_target_iam_role" {
  name               = "aws-ec2role-for-vault-authmethod"
  assume_role_policy = data.aws_iam_policy_document.client_policy.json
  managed_policy_arns = [data.aws_iam_policy.security_compute_access.arn]
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "demo_profile"
  role = aws_iam_role.vault_target_iam_role.name
}

resource "aws_iam_user" "vault_mount_user" {
  name                 = "demo-${local.my_email}"
  permissions_boundary = data.aws_iam_policy.demo_user_permissions_boundary.arn
  force_destroy        = true
}

resource "aws_iam_user_policy_attachment" "vault_mount_user" {
  user       = aws_iam_user.vault_mount_user.name
  policy_arn = data.aws_iam_policy.demo_user_permissions_boundary.arn
}

resource "aws_iam_access_key" "vault_mount_user" {
  user = aws_iam_user.vault_mount_user.name
}

resource "vault_auth_backend" "aws" {
  type = "aws"
}

resource "vault_aws_auth_backend_client" "client" {
  backend    = vault_auth_backend.aws.path
  access_key = aws_iam_access_key.vault_mount_user.id
  secret_key = aws_iam_access_key.vault_mount_user.secret
}

resource "vault_aws_auth_backend_config_identity" "identity_config" {
  backend   = vault_auth_backend.aws.path
  iam_alias = "role_id"
  iam_metadata = [
    "account_id",
    "auth_type",
    "canonical_arn",
    "client_arn",
    "client_user_id"]
}

resource "vault_aws_auth_backend_role" "role" {
  backend                  = vault_auth_backend.aws.path
  role                     = "nextjs-demo-app"
  auth_type                = "iam"
  bound_iam_principal_arns = ["arn:aws:iam::390101570318:role/nextjs-demo-app","arn:aws:iam::390101570318:instance-profile/nextjs-demo-app*","arn:aws:sts::390101570318:assumed-role/nextjs-demo-app/*"]
  token_ttl                = 3600
  token_max_ttl            =  604800
  token_policies           = ["nextjs-demo-app"]
}

resource "aws_iam_instance_profile" "iam_profile" {
  name = "nextjs-demo-app"
  role = aws_iam_role.nextjs_demo_app.name
}

resource "aws_iam_role" "nextjs_demo_app" {
  name               = "nextjs-demo-app"
  assume_role_policy = var.IAM_BASE_POLICY
}

variable "IAM_BASE_POLICY" {
  type        = string
  description = "default policy"
  default     = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
            "Service": [
            "ec2.amazonaws.com"
            ]
        },
        "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}  