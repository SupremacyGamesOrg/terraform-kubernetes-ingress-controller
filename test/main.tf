provider "kubernetes" {

    //
    // Add connection info here
    //

}

module "test" {

    source = "../"

    name      = "my-ngress-controller"
    namespace = "default"

}
