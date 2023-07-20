module "eks" {
  source = "git::github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v17.24.0"

  cluster_name                    = local.cluster_name
  cluster_version                 = local.cluster_version
  cluster_endpoint_private_access = "true"
  cluster_endpoint_public_access  = "false"
  cluster_enabled_log_types       = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  cluster_create_endpoint_private_access_sg_rule = "true"
  cluster_endpoint_private_access_cidrs          = ["10.0.0.0/8"]

  enable_irsa = true

  write_kubeconfig = false

  subnets = [module.vpc.private_subnets[0],
             module.vpc.private_subnets[1]]
  vpc_id  = module.vpc.vpc_id

  # kubeconfig_name = local.cluster_name
  # kubeconfig_aws_authenticator_env_variables = {
  #   AWS_PROFILE = local.aws_profile
  # }

  node_groups_defaults = {
    key_name               = local.key_name
    disk_size              = 20
    create_launch_template = true
    disk_type              = "gp3"
    pre_userdata           = file("${path.module}/user-data.sh")
  }

  node_groups = {

    "monitoring-pv" = {
      desired_capacity    = 3
      max_capacity        = 5
      min_capacity        = 1
      ami_release_version = local.ami_release_version
      ami_type            = "AL2_x86_64" 
      instance_types      = ["t3.large"]
      k8s_labels = {
        "node-group" = "monitoring-pv"
      }
      additional_tags = {
        "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
        "k8s.io/cluster-autoscaler/enabled"               = true
        "Name"                                            = "${local.cluster_name}-monitoring"
      }
    }
  }
}

locals {
  cluster_name        = "demo"
  cluster_version     = "1.25"
  key_name            = "teste-anna-develop-ohio"
  aws_profile         = "development"
  ami_release_version = "1.25.11-20230711" #https://github.com/awslabs/amazon-eks-ami/releases
  thumbprint_eks      = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280" // get from https://github.com/terraform-aws-modules/terraform-aws-eks/blob/a26c9fd0c9c880d5b99c438ad620e91dda957e10/variables.tf#L343

}