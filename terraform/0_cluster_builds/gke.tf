module "gke_clusters_autopilot" {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/gke-cluster-autopilot?ref=v34.0.0"

  for_each = { for cluster in local.gke_clusters : cluster.region => cluster if cluster.type == "autopilot" }

  project_id = module.project.project_id
  name       = format("%s-autopilot", each.value.region)
  location   = each.value.region

  vpc_config = {
    network    = module.vpc.name
    subnetwork = module.vpc.subnets[format("%s/%s-%s", each.value.region, module.vpc.name, each.value.region)].name

    secondary_range_names = {
      pods     = "pods"
      services = "services"
    }
  }

  private_cluster_config = {
    enable_private_endpoint = false
    master_global_access    = false
  }

  enable_addons = {
    config_connector = false
  }

  enable_features = {
    workload_identity = true
    dataplane_v2      = true
  }

  labels = {
    environment = "dev"
  }

  deletion_protection = false
}

module "gke_clusters_standard" {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/gke-cluster-standard?ref=v34.0.0"

  for_each = { for cluster in local.gke_clusters : cluster.region => cluster if cluster.type == "standard" }

  project_id = module.project.project_id
  name       = format("%s-standard", each.value.region)
  location   = each.value.region

  vpc_config = {
    network    = module.vpc.name
    subnetwork = module.vpc.subnets[format("%s/%s-%s", each.value.region, module.vpc.name, each.value.region)].name

    secondary_range_names = {
      pods     = "pods"
      services = "services"
    }

    # master_authorized_ranges = {
    #   internal-vms = "10.0.0.0/8"
    # }

    master_ipv4_cidr_block = "10.200.0.0/24"
  }

  # private_cluster_config = {
  #   enable_private_endpoint = false
  #   master_global_access    = false
  #   enable_private_nodes    = true
  # }

  enable_addons = {
    config_connector           = false
    horizontal_pod_autoscaling = true
  }

  enable_features = {
    workload_identity = true
    dataplane_v2      = true
  }

  deletion_protection = false
}

module "gke_nodepools_standard" {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/gke-nodepool?ref=v34.0.0"

  for_each = { for cluster in local.gke_clusters : cluster.region => cluster if cluster.type == "standard" }

  project_id   = module.project.project_id
  name         = format("%s-nodepool-1", each.value.region)
  location     = each.value.region
  cluster_name = module.gke_clusters_standard[each.key].name

  node_config = {
    machine_type        = "n2-standard-2"
    disk_size_gb        = 50
    disk_type           = "pd-ssd"
    ephemeral_ssd_count = 1
    spot                = true
  }
}

module "hub" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/gke-hub?ref=master"
  project_id = module.project.project_id

  clusters = {
    for cluster in module.gke_clusters_standard : cluster.name => cluster.id
  }

  features = {
    appdevexperience             = false
    configmanagement             = true
    identityservice              = false
    multiclusteringress          = null
    servicemesh                  = true
    multiclusterservicediscovery = false
  }

  configmanagement_clusters = {
    "default" = [for cluster in module.gke_clusters_standard : cluster.name]
  }

  configmanagement_templates = {
    default = {
      config_sync = {
        git = {
          policy_dir    = "configsync"
          source_format = "hierarchy"
          sync_branch   = "main"
          sync_repo     = "https://github.com/danielmarzini/configsync-platform-example"
        }
        source_format = "hierarchy"
      }
      policy_controller = {
        audit_interval_seconds     = 120
        log_denies_enabled         = true
        referential_rules_enabled  = true
        template_library_installed = true
      }
      version = "1.19.2"
    }
  }

  workload_identity_clusters = [for cluster in module.gke_clusters_standard : cluster.name]

  depends_on = [module.gke_nodepools_standard]
}