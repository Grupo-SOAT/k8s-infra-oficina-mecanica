module "gateway_under_test" {
  source = "../"

  api_name = var.api_name

  project_name = var.project_name

  resources = var.resources
}
