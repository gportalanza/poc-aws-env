terraform {
    required_providers {
        aws = "~> 1.0"
    }
}

#Configure the AWS provider
provider "aws" {
    region = "${var.region}"
    #region = "us-east-1"
}

# Additional provider configuration for west coast region
provider "aws" {
    alias = "west_region"
    region = "us-west-2"
}
