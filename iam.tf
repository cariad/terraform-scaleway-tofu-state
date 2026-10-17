# Plans and applies reach the stored state through API keys belonging to these
# applications.
#
# The caller has to create the API keys by hand in the Scaleway console. If we
# created the keys in here, OpenTofu would store their secrets in the
# bootstrap's state. We intentionally force the caller to take responsibility
# for creating and rotating their own secrets.

# For plans, which only read the state and don't take its lock.
resource "scaleway_iam_application" "state_reader" {
  description = "Reads the OpenTofu state for ${var.workload}"
  name        = local.reader_name

  # The provider doesn't check names, so we need to take responsibility.
  lifecycle {
    precondition {
      condition     = length(local.reader_name) <= 64
      error_message = "The name is too long."
    }
  }
}

# Lets the reader's API keys read objects and nothing else.
resource "scaleway_iam_policy" "state_reader" {
  application_id = scaleway_iam_application.state_reader.id
  description    = "Read the OpenTofu state for ${var.workload}"
  name           = local.reader_name

  rule {
    permission_set_names = ["ObjectStorageObjectsRead"]
    project_ids          = [scaleway_account_project.state.id]
  }
}

# For applies, which read and write the state, and take and release its lock.
resource "scaleway_iam_application" "state_writer" {
  description = "Reads and writes the OpenTofu state for ${var.workload}"
  name        = local.writer_name

  # The provider doesn't check names, so we need to take responsibility.
  lifecycle {
    precondition {
      condition     = length(local.writer_name) <= 64
      error_message = "The name is too long."
    }
  }
}

# Gives the writer's API keys only what an apply needs.
resource "scaleway_iam_policy" "state_writer" {
  application_id = scaleway_iam_application.state_writer.id
  description    = "Read and write the OpenTofu state for ${var.workload}"
  name           = local.writer_name

  rule {
    permission_set_names = [
      "ObjectStorageObjectsDelete",
      "ObjectStorageObjectsRead",
      "ObjectStorageObjectsWrite",
    ]
    project_ids = [scaleway_account_project.state.id]
  }
}
