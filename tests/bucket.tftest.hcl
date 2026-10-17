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

variables {
  bucket   = "test-bucket"
  workload = "test-project"
}

run "names_the_bucket_after_the_input" {
  command = plan

  assert {
    condition     = scaleway_object_bucket.state.name == "test-bucket"
    error_message = "The bucket must be named by `bucket`."
  }
}

run "keeps_old_versions_and_encrypts_the_state" {
  command = plan

  assert {
    condition     = one(scaleway_object_bucket.state.versioning).enabled
    error_message = "The bucket must keep old versions of the state."
  }

  assert {
    condition     = one(scaleway_object_bucket.state.lifecycle_rule).enabled
    error_message = "The bucket's lifecycle rule must be enabled."
  }

  assert {
    condition     = one(one(scaleway_object_bucket.state.lifecycle_rule).noncurrent_version_expiration).newer_noncurrent_versions == 10
    error_message = "The bucket must always keep the 10 newest old versions."
  }

  assert {
    condition     = one(one(scaleway_object_bucket.state.lifecycle_rule).noncurrent_version_expiration).noncurrent_days == 30
    error_message = "The bucket must delete other old versions after 30 days."
  }

  assert {
    condition     = one(one(scaleway_object_bucket_server_side_encryption_configuration.state.rule).apply_server_side_encryption_by_default).sse_algorithm == "AES256"
    error_message = "The bucket must encrypt new objects by default."
  }
}

run "rejects_a_bucket_name_with_dots" {
  command = plan

  expect_failures = [var.bucket]

  variables {
    bucket = "example.tofu.state"
  }
}

run "rejects_a_bucket_name_with_capitals" {
  command = plan

  expect_failures = [var.bucket]

  variables {
    bucket = "Test-bucket"
  }
}

run "rejects_a_bucket_name_shorter_than_3_characters" {
  command = plan

  expect_failures = [var.bucket]

  variables {
    bucket = "ab"
  }
}

run "rejects_a_bucket_name_longer_than_63_characters" {
  command = plan

  expect_failures = [var.bucket]

  variables {
    bucket = "0123456789012345678901234567890123456789012345678901234567890123"
  }
}

run "rejects_a_bucket_name_starting_with_a_hyphen" {
  command = plan

  expect_failures = [var.bucket]

  variables {
    bucket = "-test-bucket"
  }
}

run "rejects_a_bucket_name_ending_with_a_hyphen" {
  command = plan

  expect_failures = [var.bucket]

  variables {
    bucket = "test-bucket-"
  }
}
