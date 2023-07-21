provider "grafana" {
  #url  = "https://${module.amg.workspace_endpoint}"
  #auth = module.amg.workspace_api_key
  #url = "https://prasadrayudu93.grafana.net/"
  #auth = "glsa_itdH1N8hMAKeu01aFPa7fInTIufRrPIB_b11ca43d"
  
  url  = var.grafana_url
  auth = var.grafana_auth_token

}


