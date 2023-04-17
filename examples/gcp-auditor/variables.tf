variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "organization_id" {
  type = string
}

variable "filter" {
  type = string
}

variable "secrets" {
  type = map(string)
}

variable "docker_image" {
  type = string
}
