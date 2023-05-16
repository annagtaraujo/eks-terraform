#-------------------------------------------------------------------
#------------------------------CLUSTER------------------------------
#-------------------------------------------------------------------

resource "aws_eks_cluster" "demo" {
  name = "demo"
  role_arn = aws_iam_role.demo.arn

  vpc_config {
    security_group_ids      = [aws_security_group.eks_cluster.id, aws_security_group.eks_nodes.id]
    #vpc_id                  = module.vpc.vpc_id
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
    subnet_ids = [
      module.vpc.private_subnets[0],
      module.vpc.private_subnets[1],
      module.vpc.public_subnets[1],
      module.vpc.public_subnets[0]
    ] 
  }

  depends_on = [aws_iam_role_policy_attachment.demo-AmazonEKSClusterPolicy,
    aws_security_group_rule.cluster_egress_internet,
    aws_security_group_rule.cluster_http_inbound,
    aws_iam_role_policy_attachment.demo-AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.demo-AmazonEKSVPCResourceControllerPolicy
  ]
}

data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.demo.id
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.demo.name
}

#-------------------------------------------------------------------
#---------------------------NODE GROUP------------------------------
#-------------------------------------------------------------------

resource "aws_eks_node_group" "private-nodes" {
  cluster_name    = aws_eks_cluster.demo.name
  node_group_name = "private-nodes"
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids = [
    module.vpc.private_subnets[0],
    module.vpc.private_subnets[1]
  ]

  ami_type       = "AL2_x86_64" # AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM
  capacity_type  = "ON_DEMAND"
  instance_types = ["t2.medium"]
  disk_size      = 20

  scaling_config {
    desired_size = 1
    max_size     = 5
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  remote_access {
    ec2_ssh_key               = "teste-anna-develop-ohio"
    source_security_group_ids = [aws_security_group.eks_cluster.id, aws_security_group.eks_nodes.id]
  }

  # taint {
  #   key    = "team"
  #   value  = "devops"
  #   effect = "NO_SCHEDULE"
  # }

  # launch_template {
  #   name    = aws_launch_template.eks-with-disks.name
  #   version = aws_launch_template.eks-with-disks.latest_version
  # }

  depends_on = [
    aws_security_group_rule.workers_egress_internet,
    aws_security_group_rule.nodes_internal,
    aws_security_group_rule.workers_ingress_cluster,
    aws_security_group_rule.workers_ingress_cluster_kubelet,
    aws_security_group_rule.workers_ingress_cluster_https,
    aws_security_group_rule.workers_ingress_cluster_primary,
    aws_security_group_rule.cluster_primary_ingress_workers,
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly
  ]
}

# resource "aws_launch_template" "eks-with-disks" {
#   name = "eks-with-disks"

#   key_name = "local-provisioner"

#   block_device_mappings {
#     device_name = "/dev/xvdb"

#     ebs {
#       volume_size = 50
#       volume_type = "gp2"
#     }
#   }
# }