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

variable "docker_image" {
  type = string
}

variable "ingress" {
  type = string
}

variable "env_secret_id" {
  type = string
}

variable "container_args" {
  type = list(string)
}
