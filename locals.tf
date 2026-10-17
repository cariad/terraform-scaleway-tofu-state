# The applications and policies are named after `workload`, with a suffix that
# says what their API keys can do.
locals {
  reader_name = "${var.workload}-reader"
  writer_name = "${var.workload}-writer"
}
