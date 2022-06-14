terraform {
 backend "s3" {
   bucket         = "irida-deployment-state-bucket"
   key            = "state/terraform-irida.tfstate"
   region         = "ca-central-1"
   encrypt        = true
   kms_key_id     = "alias/terraform-bucket-key"
   dynamodb_table = "terraform-state"
 }
}