language {
  compatible_with {
    opentofu = ">= 1.12.0"
  }
}

terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.83.1, < 3.0.0"
    }
  }
}
