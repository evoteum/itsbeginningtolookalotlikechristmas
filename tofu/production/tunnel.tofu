resource "random_bytes" "tunnel_secret" {
  length = 32
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "tunnel" {
  account_id = data.cloudflare_zone.zone.account_id
  name       = "itsbeginningtolookalotlikechristmas"
  secret     = random_bytes.tunnel_secret.base64
  config_src = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "config" {
  account_id = data.cloudflare_zone.zone.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.tunnel.id

  config {
    ingress_rule {
      hostname = var.domain
      service  = "http://site.itsbeginningtolookalotlikechristmas.svc.cluster.local:8080"
    }
    ingress_rule {
      service = "http_status:404"
    }
  }
}

output "tunnel_token" {
  value     = cloudflare_zero_trust_tunnel_cloudflared.tunnel.tunnel_token
  sensitive = true
}
