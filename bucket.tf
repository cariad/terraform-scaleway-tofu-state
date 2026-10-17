# The bucket that holds the state.
resource "scaleway_object_bucket" "state" {
  name       = var.bucket
  project_id = scaleway_account_project.state.id
  region     = var.region

  # Destroying the bucket would lose every state in it, so don't make it easy.
  lifecycle {
    prevent_destroy = true
  }

  # Keep some previous versions of the state so the caller can roll back, but
  # don't keep them all forever.
  lifecycle_rule {
    enabled = true
    id      = "expire-noncurrent-versions"

    # Always keep the 10 latest versions, but delete the rest after 30 days.
    noncurrent_version_expiration {
      newer_noncurrent_versions = 10
      noncurrent_days           = 30
    }
  }

  # Keep some previous versions of the state so the caller can roll back.
  versioning {
    enabled = true
  }
}

# The state holds secrets, so encrypt the bucket.
resource "scaleway_object_bucket_server_side_encryption_configuration" "state" {
  bucket     = scaleway_object_bucket.state.name
  project_id = scaleway_object_bucket.state.project_id
  region     = scaleway_object_bucket.state.region

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
