variable "region" {
  default = "ap-south-1"
}

variable "app_image" {
  description = "ECR image URL for app"
}

variable "db_username" {
  default = "admin"
}

variable "db_password" {
  default = "Admin12345"
}

