terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

#No Idea why you using 3.0? Newest is 4.59.0, set it to atleast 5

provider "aws" {
  region = "eu-west-2"
  # use for credentials stored in default location
  # shared_credentials_file = "~/.aws/credentials"
  profile = "default"
}

# Maybe Write these comments out a bit nicer?


# GOOD TO KNOW!
# terraform validate - Makes sure the code is runnable without init etc. Checks alot!
# terraform fmt - Makes it all look pretty! Will correctly indent stuff etc. Make it nice, good to run before pishing as keeps it looking neat!