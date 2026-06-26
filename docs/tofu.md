# Why OpenTofu is in use

IaC for this project was originally written in Terraform, so when we migrated into
Kubernetes, we clearly wanted to migrate into Crossplane too. Unfortunately, the
Cloudflare provider for crossplane has no release, so is not ready for use.

[provider-upjet-cloudflare](https://github.com/crossplane-contrib/provider-upjet-cloudflare)

Once they cut a release, we will be able to complete the migration.