data "tls_certificate" "eks" {
  url = module.eks.cluster_oidc_issuer_url
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
