terraform {
  required_version = ">= 1.4.0"


  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = ">= 1.28.2"
    }
  }

}

