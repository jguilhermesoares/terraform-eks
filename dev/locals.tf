locals {
  # Update Strategy:
  #   Phase 1: Addon modules
  #   Phase 2: Cluster version 
  #   Phase 3: AMI version

  # Warning: Updating everything all at one will break the cluster. 
  # See Readme for more information

  name            = "eks-dev-cluster"
  region          = "us-east-1"
  cluster_version = "1.28"

  vpc_cidr        = "10.255.144.0/20"
  public_subnets  = ["10.255.144.0/23", "10.255.146.0/23", "10.255.148.0/23", "10.255.150.0/23"]
  private_subnets = ["10.255.152.0/23", "10.255.154.0/23", "10.255.156.0/23", "10.255.158.0/23"]
  azs             = slice(data.aws_availability_zones.available.names, 0, 4)

  node_group_name = "managed-ondemand"

  # Ami version https://github.com/awslabs/amazon-eks-ami/releases
  mng_release_version = "1.28.5-20240110"

  # Addon Versions
  eks_vpc_cni_version    = "v1.16.0-eksbuild.1"
  coredns_version        = "v1.10.1-eksbuild.6"
  kube_proxy_version     = "v1.28.4-eksbuild.4"
  ebs_csi_driver_version = "v1.26.1-eksbuild.1"
}
