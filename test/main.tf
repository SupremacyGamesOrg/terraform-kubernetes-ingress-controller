module "test" {

    source = "../"

    name         = "ingress-controller"
    namespace    = "default"
    aws_profile  = "myawsprofilename"
    aws_region   = "us-east-1"
    cluster_name = "cluster-1"

}
