module "vpc" {
  source = "git@github.com:terraform-aws-modules/terraform-aws-vpc.git?ref=v3.19.0"

  name                   = "minha-vpc"
  cidr                   = "10.0.0.0/16"

  azs                    = ["us-east-2a", "us-east-2b"]
  private_subnet_suffix  = "subnet-pv"
  private_subnets        = ["10.0.0.0/19", "10.0.32.0/19"]
  public_subnet_suffix   = "subnet-pb"
  public_subnets         = ["10.0.64.0/19", "10.0.96.0/19"]

  enable_nat_gateway     = true
  one_nat_gateway_per_az = true
  enable_dns_hostnames   = true

  public_subnet_tags_per_az = {
    "${local.region}a" = {
      "availability-zone" = "${local.region}a",
      "kubernetes.io/role/elb" = "1",
      "kubernetes.io/cluster/demo" = "shared"
    }
    "${local.region}b" = {
      "availability-zone" = "${local.region}b",
      "kubernetes.io/role/elb" = "1",
      "kubernetes.io/cluster/demo" = "shared"
    }
  }
  
  private_subnet_tags_per_az = {
    "${local.region}a" = {
      "availability-zone" = "${local.region}a",
      "kubernetes.io/role/internal-elb" = "1",
      "kubernetes.io/cluster/demo" = "shared"
    }
    "${local.region}b" = {
      "availability-zone" = "${local.region}b",
      "kubernetes.io/role/internal-elb" = "1",
      "kubernetes.io/cluster/demo" = "shared"
    }
  }
  
  tags = {
    Terraform = "true"
    Environment = "dev"
    "kubernetes.io/cluster/demo" = "shared"
  }
}

locals{
  region = "us-east-2"
}

