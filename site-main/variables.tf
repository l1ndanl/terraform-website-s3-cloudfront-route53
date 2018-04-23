variable region {
  default = "us-east-1"
}

variable project {
  default = "noproject"
}
variable environment {
  default = "default"
}

variable domain {}

variable bucket_name {
  description = "The name of the S3 bucket to create."
}

variable deployer {
  description = "Name of user allowed to deploy to the bucket; optional"
  default     = ""
}

variable acm-certificate-arn {}

variable routing_rules {
  default = ""
}

variable not-found-response-path {
  default = "/404.html"
}

variable not-authorized-response-path {
  default = "/403.html"
}

variable "tags" {
  type        = "map"
  description = "Optional Tags"
  default     = {}
}

variable "trusted_signers" {
  type = "list"
  default = []
}

variable "forwarded-headers" {
  type = "list"
  default = ["Origin"]
}

variable "forward-query-string" {
  description = "Forward the query string to the origin"
  default     = false
}

variable "cors-allowed-methods" {
  type = "list"
  default = ["GET", "HEAD"]
  description = "Specifies which methods are allowed. Can be GET, PUT, POST, DELETE or HEAD."
}

variable "cors-allowed-origins" {
  type = "list"
  default = ["*"]
  description = "Specifies which origins are allowed."
}

variable "cors-allowed-headers" {
  type = "list"
  default = []
  description = "Specifies which headers are allowed."
}

variable "cors-expose-headers" {
  type = "list"
  default = []
  description = "Specifies expose header in the response."
}

variable "cors-max-cache-age-seconds" {
  default = "60"
  description = "Specifies time in seconds that browser can cache the response for a preflight request."
}

variable "price_class" {
  description = "CloudFront price class"
  default     = "PriceClass_200"
}
