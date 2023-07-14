module "vpc_sg" {
  source = "git@github.com:terraform-aws-modules/terraform-aws-security-group?ref=v4.17.0"

  name        = "vpc-sg"
  description = "Security group for VPC subnets"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]

  ingress_with_cidr_blocks = [
    {
      description      = "Allow all traffic from the cluster control plane"
      from_port        = 0
      to_port          = 0
      protocol         = -1
      cidr_blocks      = "0.0.0.0/0"
    }
  ]
  
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

# # ------------------- SG para Jumpbox --------------------------

module "jumpbox-sg" {
  source = "git@github.com:terraform-aws-modules/terraform-aws-security-group?ref=v4.17.0"

  name        = "jumpbox-sg"
  description = "Security group for Jumpbox"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]

  ingress_with_cidr_blocks = [
    {
      description      = "Allow SSH"
      from_port        = 22
      to_port          = 22
      protocol         = -1
      cidr_blocks      = "0.0.0.0/0"
    }
  ]
  
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}