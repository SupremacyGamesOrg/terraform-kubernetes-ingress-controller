module "test" {

    source = "../"

    name      = "ingress-controller"
    namespace = "default"
    aws_profile = "odin"
    aws_region = "us-east-1"
    cluster_name = "odin-devops-1"

}
