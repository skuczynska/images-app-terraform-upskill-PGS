variable "email" {
  type    = string
  default = "skuczynska@pgs-soft.com"
}

variable "protocol" {
  default     = "email"
  description = "SNS Protocol to use. email or email-json"
  type        = string
}