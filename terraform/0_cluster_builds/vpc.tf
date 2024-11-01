module "vpc" {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/net-vpc?ref=v34.0.0"

  project_id = module.project.project_id
  name       = "core"

  subnets = [
    {
      ip_cidr_range = "10.0.0.0/23" # 10.0.0.1-10.0.1.255 (510 usable addresses)
      name          = "core-northamerica-northeast2"
      region        = "northamerica-northeast2"
      secondary_ip_ranges = {
        pods     = "10.0.48.0/22" # 10.0.48.1-10.0.51.254 (1,022 usable addresses)
        services = "10.0.52.0/24" # 10.0.52.1-10.0.52.254 (256 addresses)
      }
    },
    {
      ip_cidr_range = "10.100.0.0/23" # 10.100.0.1-10.100.1.255 (510 usable addresses)
      name          = "core-us-west4"
      region        = "us-west4"
      secondary_ip_ranges = {
        pods     = "10.100.48.0/22" # 10.100.48.1-10.100.51.254 (1,022 usable addresses)
        services = "10.100.52.0/24" # 10.100.52.1-10.100.52.255 (256 addresses)
      }
    }
  ]
}