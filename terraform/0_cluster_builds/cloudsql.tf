# module "cloudsql_database" {
#   source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/cloudsql-instance?ref=v34.0.0"

#   project_id       = module.project.project_id
#   name             = "db"
#   region           = var.region
#   database_version = "SQLSERVER_2019_STANDARD"
#   tier             = "db-custom-1-4096"

#   network_config = {
#     authorized_networks = {
#       all = "0.0.0.0/0"
#     }
#     connectivity = {
#       public_ipv4 = true
#     }
#   }

#   root_password                 = "J@c0B!f4f9*s"
#   gcp_deletion_protection       = false
#   terraform_deletion_protection = false
# }