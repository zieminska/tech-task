variable "db_name" {
  default = "demodb"
}

variable "db_port" {
  type    = number
  default = 5432
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "https_port" {
  type    = number
  default = 443
}

variable "product_name" {
  type    = string
  default = "demo-app"
}