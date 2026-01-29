# -----------------------------------------------------------------------------
# IAM Role - EKS Cluster Control Plane
# -----------------------------------------------------------------------------

# IAM role that the EKS service assumes to manage the cluster control plane.
resource "aws_iam_role" "eks_cluster" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.cluster_name}-cluster-role"
  }
}

# Attaches the AmazonEKSClusterPolicy to the cluster IAM role.
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# Attaches the AmazonEKSVPCResourceController policy to the cluster IAM role.
# Required for security groups for pods and managed ENIs.
resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster.name
}

# -----------------------------------------------------------------------------
# IAM Role - EKS Node Group
# -----------------------------------------------------------------------------

# IAM role that EC2 instances in the node group assume.
resource "aws_iam_role" "eks_nodes" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.cluster_name}-node-role"
  }
}

# Attaches the AmazonEKSWorkerNodePolicy to the node IAM role.
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

# Attaches the AmazonEKS_CNI_Policy to the node IAM role.
# Required for the VPC CNI plugin to manage pod networking.
resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

# Attaches the AmazonEC2ContainerRegistryReadOnly policy to the node IAM role.
# Required for nodes to pull container images from ECR.
resource "aws_iam_role_policy_attachment" "eks_ecr_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

# -----------------------------------------------------------------------------
# Security Group - EKS Cluster
# -----------------------------------------------------------------------------

# Security group for the EKS cluster control plane.
resource "aws_security_group" "eks_cluster" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "Security group for the EKS cluster control plane"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.cluster_name}-cluster-sg"
  }
}

# Allows all outbound traffic from the cluster control plane.
resource "aws_security_group_rule" "cluster_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_cluster.id
  description       = "Allow all outbound traffic"
}

# Allows inbound HTTPS traffic to the cluster API server.
resource "aws_security_group_rule" "cluster_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_cluster.id
  description       = "Allow HTTPS traffic to the Kubernetes API server"
}

# -----------------------------------------------------------------------------
# EKS Cluster
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster
# -----------------------------------------------------------------------------

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = [aws_security_group.eks_cluster.id]
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller,
  ]

  tags = {
    Name = var.cluster_name
  }
}

# -----------------------------------------------------------------------------
# EKS Managed Node Group
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group
# -----------------------------------------------------------------------------

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = var.private_subnet_ids

  instance_types = var.node_instance_types
  disk_size      = var.node_disk_size
  capacity_type  = "SPOT"

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_read_only,
  ]

  tags = {
    Name = "${var.cluster_name}-node-group"
  }
}

# -----------------------------------------------------------------------------
# OIDC Provider for IAM Roles for Service Accounts (IRSA)
# -----------------------------------------------------------------------------

# TLS certificate data for the EKS OIDC provider.
data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

# IAM OpenID Connect provider for EKS IRSA.
# Enables Kubernetes service accounts to assume IAM roles.
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = {
    Name = "${var.cluster_name}-oidc-provider"
  }
}

# -----------------------------------------------------------------------------
# Subnet Tags for EKS Discovery
# -----------------------------------------------------------------------------

# Tags private subnets for EKS internal load balancer discovery.
resource "aws_ec2_tag" "private_subnet_elb" {
  count       = length(var.private_subnet_ids)
  resource_id = var.private_subnet_ids[count.index]
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}

# Tags private subnets with the EKS cluster name for ownership.
resource "aws_ec2_tag" "private_subnet_cluster" {
  count       = length(var.private_subnet_ids)
  resource_id = var.private_subnet_ids[count.index]
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "shared"
}
