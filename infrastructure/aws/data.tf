variable "TFC_ORG" {
    type = string
    default = "hashicoop"
} 

variable "TFC_NETWORK_WORKSPACE" {
    type = string
    default = "aws-base"
}

data "tfe_outputs" "network" {
  organization = var.TFC_ORG
  workspace    = var.TFC_NETWORK_WORKSPACE
}