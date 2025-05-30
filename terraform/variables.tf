variable "project_id" {}
variable "region" {
  default = "europe-west3"
}
variable "zone" {
  default = "europe-west3-c"
}

variable "credentials_file" {
  default = "../secrets/credentials.json"
}
variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}