# Kubernetes ingress controller via Terraform

See https://registry.terraform.io/modules/mateothegreat/ingress-controller/kubernetes/latest.

## Example

```hcl
provider "kubernetes" {

    //
    // Add connection info here
    //

}

module "ingress-controller" {

    source  = "mateothegreat/ingress-controller/kubernetes"
    version = "<change me>"

    name      = "my-ngress-controller"
    namespace = "default"
    internal  = true
    
}
```
