# Define the data block to access the workspace_api_key output from Terraform Cloud
data "terraform_remote_state" "amg" {
  backend = "remote"

  config = {
    organization = "sph"
    workspaces = {
      name = "mlops-eks-cluster-dev" # Replace with the name of the workspace where the amg module is running
    }
  }
}

# Use the data source to retrieve the workspace_api_key output from Terraform Cloud
provider "grafana" {
  url  = "https://${data.terraform_remote_state.amg.outputs.workspace_endpoint}"
  auth = data.terraform_remote_state.amg.outputs.workspace_api_key
}

/*
provider "grafana" {
  #url  = "https://${module.amg.workspace_endpoint}"
  #auth = module.amg.workspace_api_key
  #url = "https://prasadrayudu93.grafana.net/"
  #auth = "glsa_itdH1N8hMAKeu01aFPa7fInTIufRrPIB_b11ca43d"

  url  = var.grafana_url
  auth = var.grafana_auth_token

  
}
*/

