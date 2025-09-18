# Terraform EKS Cluster

A production-ready Amazon EKS (Elastic Kubernetes Service) cluster deployment using Terraform and the AWS EKS Blueprints framework.

## 🏗️ Architecture Overview

This repository deploys a complete EKS cluster with the following components:

- **EKS Cluster** (v1.28) with managed node groups
- **VPC** with public/private subnets across multiple AZs
- **Karpenter** for automatic node provisioning and scaling
- **AWS Load Balancer Controller** for ingress management
- **Calico** for network policies and CNI
- **Essential EKS Add-ons** (VPC CNI, CoreDNS, Kube Proxy, EBS CSI Driver)
- **GitHub Actions** for CI/CD automation

## 📋 Prerequisites

Before deploying this infrastructure, ensure you have:

- [Terraform](https://terraform.io/downloads.html) >= 1.13.3
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- [kubectl](https://kubernetes.io/docs/tasks/tools/) for cluster management
- Terraform Cloud account (configured for remote state)
- GitHub repository with required secrets configured

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/jguilhermesoares/terraform-eks.git
cd terraform-eks
```

### 2. Configure Terraform Cloud

Update the backend configuration in `dev/backend.tf`:

```terraform
terraform {
  cloud {
    organization = "your-terraform-cloud-org"
    workspaces {
      name = "terraform-eks-deploy-dev"
    }
  }
}
```

### 3. Review and Customize Configuration

Edit `dev/locals.tf` to customize your deployment:

```terraform
locals {
  name            = "eks-dev-cluster"      # Cluster name
  region          = "us-east-1"            # AWS region
  cluster_version = "1.28"                 # EKS version
  vpc_cidr        = "10.255.144.0/20"      # VPC CIDR block
  # ... other configurations
}
```

### 4. Deploy Using GitHub Actions

The repository includes GitHub Actions workflows for automated deployment:

- **Plan**: `.github/workflows/plan.yaml` - Run `terraform plan`
- **Apply**: `.github/workflows/apply.yml` - Deploy infrastructure

Trigger deployment manually through GitHub Actions or configure automatic triggers.

### 5. Local Deployment (Alternative)

```bash
cd dev
terraform init
terraform plan
terraform apply
```

## 🔧 Configuration Details

### Cluster Specifications

- **EKS Version**: 1.28
- **Node Groups**: m5.xlarge instances with managed scaling
- **Networking**: Custom VPC with public/private subnets
- **Security**: IAM roles with least privilege access

### Add-ons Included

| Add-on | Version | Purpose |
|--------|---------|---------|
| VPC CNI | v1.16.0-eksbuild.1 | Pod networking |
| CoreDNS | v1.10.1-eksbuild.6 | DNS resolution |
| Kube Proxy | v1.28.4-eksbuild.4 | Network proxy |
| EBS CSI Driver | v1.26.1-eksbuild.1 | Persistent storage |
| AWS LB Controller | Latest | Ingress management |
| Karpenter | v0.29.0 | Node autoscaling |
| Calico | v3.24.5 | Network policies |

### Network Configuration

- **VPC CIDR**: 10.255.144.0/20
- **Availability Zones**: 4 AZs for high availability
- **Public Subnets**: For load balancers and NAT gateways
- **Private Subnets**: For EKS worker nodes and pods

## 📁 Repository Structure

```
terraform-eks/
├── .github/
│   └── workflows/
│       ├── apply.yml          # Deployment workflow
│       └── plan.yaml          # Planning workflow
├── dev/
│   ├── backend.tf             # Terraform Cloud configuration
│   ├── data.tf                # Data sources
│   ├── locals.tf              # Local values and variables
│   ├── main.tf                # Main infrastructure code
│   ├── outputs.tf             # Output values
│   ├── providers.tf           # Provider configurations
│   └── roles.tf               # IAM roles
├── LICENSE
└── README.md
```

## 🔐 Required GitHub Secrets

Configure the following secrets in your GitHub repository:

### Development Environment
- `DEV_AWS_ACCESS_KEY_ID`
- `DEV_AWS_SECRET_ACCESS_KEY`

### Production Environment
- `PROD_AWS_ACCESS_KEY_ID`
- `PROD_AWS_SECRET_ACCESS_KEY`

### Additional Secrets
- `TERRAFORM_API_TOKEN` - Terraform Cloud API token
- `GIT_HUB_TOKEN` - GitHub personal access token

## 🔄 Upgrade Strategy

⚠️ **Important**: Follow this upgrade sequence to avoid cluster downtime:

1. **Phase 1**: Update addon modules
2. **Phase 2**: Update cluster version
3. **Phase 3**: Update AMI version

**Warning**: Updating everything simultaneously will break the cluster.

## 🏃‍♂️ Post-Deployment

### Connect to Your Cluster

```bash
aws eks update-kubeconfig --region us-east-1 --name eks-dev-cluster
kubectl get nodes
```

### Verify Add-ons

```bash
# Check Karpenter
kubectl get pods -n karpenter

# Check AWS Load Balancer Controller
kubectl get pods -n kube-system | grep aws-load-balancer

# Check Calico
kubectl get pods -n tigera-operator
```

### Deploy Sample Application

```bash
# Example: Deploy a simple nginx deployment
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer
```

## 🛠️ Customization Options

### Adding New Add-ons

Extend the `kubernetes-addons` module in `main.tf`:

```terraform
module "kubernetes-addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.21.0/modules/kubernetes-addons"
  
  # Add new add-ons here
  enable_metrics_server = true
  enable_cluster_autoscaler = true
  # ... other add-ons
}
```

### Scaling Configuration

Modify node group settings in `main.tf`:

```terraform
managed_node_groups = {
  mg_5 = {
    node_group_name = local.node_group_name
    instance_types  = ["m5.xlarge"]
    min_capacity    = 2
    max_capacity    = 10
    desired_capacity = 3
  }
}
```

## 🔍 Monitoring and Observability

The cluster is configured with:

- **AWS FluentBit** (optional) for log aggregation
- **Karpenter** metrics for node provisioning insights
- **EKS control plane logs** (configurable)

## 🆘 Troubleshooting

### Common Issues

1. **IAM Permissions**: Ensure your AWS credentials have sufficient permissions for EKS, VPC, and IAM operations.

2. **Terraform State**: If you encounter state issues, check your Terraform Cloud workspace configuration.

3. **Cluster Access**: If you can't access the cluster, verify your IAM user/role is mapped correctly in the `map_roles` configuration.

### Useful Commands

```bash
# Check cluster status
aws eks describe-cluster --name eks-dev-cluster

# Get cluster endpoint
aws eks describe-cluster --name eks-dev-cluster --query cluster.endpoint

# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name eks-dev-cluster
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [AWS EKS Blueprints](https://github.com/aws-ia/terraform-aws-eks-blueprints) for the foundational modules
- [Karpenter](https://karpenter.sh/) for efficient node provisioning
- [Calico](https://projectcalico.docs.tigera.io/) for network policies

## 📞 Support

For issues and questions:

- Create an [issue](https://github.com/jguilhermesoares/terraform-eks/issues) in this repository
- Review the [EKS Blueprints documentation](https://aws-ia.github.io/terraform-aws-eks-blueprints/)
- Check [AWS EKS documentation](https://docs.aws.amazon.com/eks/)

---

**⚡ Built with ❤️ using Terraform and AWS EKS Blueprints**