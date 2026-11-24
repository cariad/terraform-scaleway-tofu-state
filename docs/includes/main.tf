module "state" {
  source = "git::https://github.com/cariad/terraform-scaleway-tofu-state.git?ref={{ git.short_tag }}"

  # Name of the bucket to create. Must be globally unique amongst all Scaleway
  # customers, so consider adding a timestamp to reduce the chance of a collision.
  #
  # bucket = "example-state-20261015"
  bucket = "..."

  # Override the default region (Paris, France) to store your state in. See the
  # Scaleway regions that offer Object Storage at:
  # https://www.scaleway.com/en/product-availability-by-region/?categories=storage
  #
  # region = "nl-ams"

  # A name for your project — for example, its domain name. Names the Scaleway
  # project and the reader and writer applications.
  #
  # workload = "example.com"
  workload = "..."
}
