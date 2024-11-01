module "docker_artifact_registry" {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/artifact-registry?ref=v34.0.0"

  project_id = module.project.project_id
  location   = var.default_region
  name       = "af-northamerica-northeast2-docker"
  format     = { docker = { standard = {} } }
}