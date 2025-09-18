terraform {
  cloud {
    organization = "jguilhermesoares"

    workspaces {
      name = "terraform-eks-deploy-dev"
    }
  }
}