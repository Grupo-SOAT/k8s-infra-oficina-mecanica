# --- CLUSTER EKS (Usando a LabRole existente) ---
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.aws_academy_role_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  tags = {

    ManagedBy = "Terraform"

    Project = "oficina-mecanica"

  }
}

# --- LAUNCH TEMPLATE (IMDS hop limit 2 para o EBS CSI driver obter credenciais) ---
resource "aws_launch_template" "this" {
  name_prefix = "${var.cluster_name}-"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      ManagedBy = "Terraform"
    }
  }
}

# --- NODE GROUP GERENCIADO (Usando a LabRole existente) ---
resource "aws_eks_node_group" "this" {

  cluster_name = aws_eks_cluster.this.name

  node_group_name = "${var.cluster_name}-node-group"

  node_role_arn = var.aws_academy_role_arn

  subnet_ids = var.subnet_ids

  instance_types = var.instance_types

  capacity_type = "ON_DEMAND"

  ami_type = "AL2023_x86_64_STANDARD"

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  scaling_config {

    desired_size = var.desired_size

    min_size = var.min_size

    max_size = var.max_size

  }

  tags = {

    ManagedBy = "Terraform"

  }

}

# --- EBS CSI driver (necessario para PersistentVolumes, ex: Loki/Tempo) ---
resource "aws_eks_addon" "ebs_csi" {
  cluster_name  = aws_eks_cluster.this.name
  addon_name    = "aws-ebs-csi-driver"
  addon_version = "v1.65.0-eksbuild.2"

  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [aws_eks_node_group.this]
}
