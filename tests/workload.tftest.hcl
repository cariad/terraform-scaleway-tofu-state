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

run "names_everything_after_the_workload" {
  command = plan

  assert {
    condition     = scaleway_account_project.state.name == "test-project"
    error_message = "The Scaleway project must be named by `workload`."
  }

  assert {
    condition     = scaleway_iam_application.state_reader.name == "test-project-reader"
    error_message = "The reader application must be named `<workload>-reader`."
  }

  assert {
    condition     = scaleway_iam_application.state_writer.name == "test-project-writer"
    error_message = "The writer application must be named `<workload>-writer`."
  }

  assert {
    condition     = scaleway_iam_policy.state_reader.name == "test-project-reader"
    error_message = "The reader policy must be named `<workload>-reader`."
  }

  assert {
    condition     = scaleway_iam_policy.state_writer.name == "test-project-writer"
    error_message = "The writer policy must be named `<workload>-writer`."
  }
}

run "describes_everything_with_the_workload" {
  command = plan

  variables {
    workload = "example.com"
  }

  assert {
    condition     = scaleway_account_project.state.description == "OpenTofu state for example.com"
    error_message = "The Scaleway project's description must use `workload`."
  }

  assert {
    condition     = scaleway_iam_application.state_reader.description == "Reads the OpenTofu state for example.com"
    error_message = "The reader application's description must use `workload`."
  }

  assert {
    condition     = scaleway_iam_application.state_writer.description == "Reads and writes the OpenTofu state for example.com"
    error_message = "The writer application's description must use `workload`."
  }

  assert {
    condition     = scaleway_iam_policy.state_reader.description == "Read the OpenTofu state for example.com"
    error_message = "The reader policy's description must use `workload`."
  }

  assert {
    condition     = scaleway_iam_policy.state_writer.description == "Read and write the OpenTofu state for example.com"
    error_message = "The writer policy's description must use `workload`."
  }
}

run "accepts_a_workload_of_57_characters" {
  command = plan

  variables {
    workload = "012345678901234567890123456789012345678901234567890123456"
  }

  assert {
    condition     = length(scaleway_iam_application.state_writer.name) == 64
    error_message = "The writer application's name must fit Scaleway's 64-character limit exactly."
  }
}

run "accepts_a_workload_with_every_allowed_character" {
  command = plan

  variables {
    workload = "Test_project.v1-0"
  }

  assert {
    condition     = scaleway_iam_application.state_reader.name == "Test_project.v1-0-reader"
    error_message = "The reader application must be named `<workload>-reader`."
  }
}

run "rejects_a_workload_longer_than_57_characters" {
  command = plan

  # Both applications' names would be 65 characters, one over Scaleway's limit.
  expect_failures = [
    scaleway_iam_application.state_reader,
    scaleway_iam_application.state_writer,
  ]

  variables {
    workload = "0123456789012345678901234567890123456789012345678901234567"
  }
}

run "rejects_a_workload_with_a_space" {
  command = plan

  expect_failures = [var.workload]

  variables {
    workload = "test project"
  }
}

run "rejects_an_empty_workload" {
  command = plan

  expect_failures = [var.workload]

  variables {
    workload = ""
  }
}
