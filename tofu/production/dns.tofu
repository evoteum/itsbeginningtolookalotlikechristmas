resource "cloudflare_record" "cname" {
  zone_id = data.cloudflare_zone.zone.id
  name    = var.domain
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.tunnel.id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
}

locals {
  dns_records = flatten(
    [
      for type, records in {
        TXT = [
          "IBTLALLC was first released in 1951 by composer Meredith Willson.",
          "Bing Crosby and Perry Como recorded two of the most popular versions of IBTLALLC.",
          "IBTLALLC has been featured in numerous holiday films and specials, solidifying its place as a Christmas classic.",
          "The song was originally written for the musical 'Here's Love,' which was based on the film 'Miracle on 34th Street.'",
          "IBTLALLC remains a holiday favourite and is streamed millions of times each Christmas season.",
          "The lyrics of IBTLALLC describe the excitement of holiday decorations appearing in public spaces.",
          "IBTLALLC has been covered by artists across genres, from jazz to pop to country.",
          "IBTLALLC is often one of the top-streamed holiday songs every December, showing its enduring appeal.",
          "Thanks for taking the time to explore the IBTLALLC project!",
        ]
        ] } : [
        for record in records : {
          type    = type
          content = record
          key     = "${type}-${index(records, record)}"
        }
        if length(record) <= 255
      ]
  ])
}

resource "cloudflare_record" "dns_records" {
  for_each = { for record in local.dns_records : record.key => record }

  zone_id = data.cloudflare_zone.zone.id
  name    = var.domain
  type    = each.value.type
  ttl     = 1
  proxied = false
  content = each.value.content
}
