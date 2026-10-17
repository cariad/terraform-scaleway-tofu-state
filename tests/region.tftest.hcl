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

run "keeps_the_state_in_paris_by_default" {
  command = plan

  assert {
    condition     = scaleway_object_bucket.state.region == "fr-par"
    error_message = "Without a `region`, the bucket must be in `fr-par`."
  }
}

run "keeps_the_state_in_the_chosen_region" {
  command = plan

  variables {
    region = "nl-ams"
  }

  assert {
    condition     = scaleway_object_bucket.state.region == "nl-ams"
    error_message = "The bucket must be in `region`."
  }
}

run "accepts_a_region_with_a_7_letter_city" {
  command = plan

  variables {
    region = "fr-abcdefg"
  }

  assert {
    condition     = scaleway_object_bucket.state.region == "fr-abcdefg"
    error_message = "The region rule must allow city codes of up to 7 letters."
  }
}

run "rejects_a_zone_as_the_region" {
  command = plan

  expect_failures = [var.region]

  variables {
    region = "fr-par-1"
  }
}

run "rejects_an_uppercase_region" {
  command = plan

  expect_failures = [var.region]

  variables {
    region = "FR-PAR"
  }
}

run "rejects_a_region_with_a_2_letter_city" {
  command = plan

  expect_failures = [var.region]

  variables {
    region = "fr-pa"
  }
}

run "rejects_a_region_with_an_8_letter_city" {
  command = plan

  expect_failures = [var.region]

  variables {
    region = "fr-abcdefgh"
  }
}
