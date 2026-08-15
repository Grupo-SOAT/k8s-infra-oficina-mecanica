# --- CLUSTER EKS (Usando a LabRole existente) ---
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.aws_academy_role_arn 
  version  = var.cluster_version

  vpc_config {
    subnet_ids = var.subnet_ids
    endpoint_public_access = true
    endpoint_private_access = true
  }

  tags = {

    ManagedBy = "Terraform"

    Project = "oficina-mecanica"

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

  scaling_config {

      desired_size = var.desired_size

      min_size = var.min_size

      max_size = var.max_size

  }

  tags = {

      ManagedBy = "Terraform"

  }

}
