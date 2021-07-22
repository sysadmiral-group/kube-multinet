locals {
    gcp_project = "run-ai-external"
    region = "us-central1"
    zone = "us-central1-b"

    net0_name = "net0"
    net0_subnet_name = "${local.net0_name}-subnet0"
    net0_subnet_cidr    = "192.168.1.0/24"

    net1_name = "net1"
    net1_subnet_name = "${local.net1_name}-subnet0"
    net1_subnet_cidr    = "10.44.1.0/24"

    machine_type_default = "n2-standard-2"
}