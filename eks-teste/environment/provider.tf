provider "aws"{
  region = local.region
  profile = "development"
}
terraform{
  required_providers{
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}