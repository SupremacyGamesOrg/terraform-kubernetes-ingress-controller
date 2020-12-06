# Kubernetes ingress controller via Terraform

```hcl
module "ingress-controller" {

    source  = "mateothegreat/ingress-controller/kubernetes"
    version = "0.0.0"

    name         = "ingress-controller"
    namespace    = "default"
    aws_profile  = "myawsprofilename"
    aws_region   = "us-east-1"
    cluster_name = "cluster-1"
    
}
```
