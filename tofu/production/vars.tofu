variable "cloudflare_api_token" {
  # Provided by env var
  description = "The API token needed to access Cloudflare"
  type        = string
  sensitive   = true
  default     = null
}

variable "domain" {
  description = "The domain of our site"
  type        = string
  sensitive   = false
  default     = "itsbeginningtolookalotlike.christmas"
}
