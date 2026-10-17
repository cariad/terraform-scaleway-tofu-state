mock_provider "scaleway" {
  mock_resource "scaleway_account_project" {
    defaults = {
      id = "11111111-1111-1111-1111-111111111111"
    }
  }

  mock_resource "scaleway_iam_application" {
    defaults = {
      id = "22222222-2222-2222-2222-222222222222"
    }
  }
}

# Gives the writer a different ID from the reader, so the tests can tell which
# application each policy belongs to.
override_resource {
  target = scaleway_iam_application.state_writer

  values = {
    id = "33333333-3333-3333-3333-333333333333"
  }
}

variables {
  bucket   = "test-bucket"
  workload = "test-project"
}

run "lets_the_reader_only_read_the_state" {
  command = plan

  assert {
    condition     = scaleway_iam_policy.state_reader.application_id == scaleway_iam_application.state_reader.id
    error_message = "The reader policy must belong to the reader application."
  }

  assert {
    condition     = toset(one(scaleway_iam_policy.state_reader.rule).permission_set_names) == toset(["ObjectStorageObjectsRead"])
    error_message = "The reader policy must only read objects."
  }

  assert {
    condition     = one(scaleway_iam_policy.state_reader.rule).project_ids == tolist([scaleway_account_project.state.id])
    error_message = "The reader policy must be limited to the Scaleway project."
  }
}

run "lets_the_writer_read_write_and_unlock_the_state" {
  command = plan

  assert {
    condition     = scaleway_iam_policy.state_writer.application_id == scaleway_iam_application.state_writer.id
    error_message = "The writer policy must belong to the writer application."
  }

  assert {
    condition = toset(one(scaleway_iam_policy.state_writer.rule).permission_set_names) == toset([
      "ObjectStorageObjectsDelete",
      "ObjectStorageObjectsRead",
      "ObjectStorageObjectsWrite",
    ])
    error_message = "The writer policy must read, write and delete objects, and nothing else."
  }

  assert {
    condition     = one(scaleway_iam_policy.state_writer.rule).project_ids == tolist([scaleway_account_project.state.id])
    error_message = "The writer policy must be limited to the Scaleway project."
  }
}
