terraform {
  required_providers {
    aws = {
      version = ">= 4.0.0"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.10.0"
    }
  }
  required_version = ">= 1.1.0"
}
