variable "bucket" {
  description = "The bucket's name."
  nullable    = false
  type        = string

  validation {
    # Stricter than Scaleway's own rules. We don't allow dots, because the
    # bucket name appears in its endpoint hostname, and a dot would break TLS.
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.bucket))
    error_message = "The bucket name must be 3 to 63 lowercase letters, digits and hyphens, starting and ending with a letter or digit."
  }
}

# Lets the caller choose where in the world their state is kept. It defaults to
# Paris so that most callers needn't choose.
#
# Never change the default: every caller that relies on it would have their
# bucket replaced, which `prevent_destroy` blocks.
variable "region" {
  default     = "fr-par"
  description = "The bucket's region."
  nullable    = false
  type        = string

  # The same pattern as Scaleway's Go SDK.
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]{3,7}$", var.region))
    error_message = "The region must be a Scaleway region code such as \"fr-par\": two lowercase letters, a hyphen, then three to seven lowercase letters."
  }
}

variable "workload" {
  description = "The name of the workload whose state this holds, such as `example.com`."
  nullable    = false
  type        = string

  # The applications check their own names' length, in `iam.tf`, because the
  # limit applies to `workload` plus their suffixes.
  validation {
    condition     = can(regex("^[A-Za-z0-9_.-]+$", var.workload))
    error_message = "The workload must be letters, digits, dots, hyphens, and underscores."
  }
}
