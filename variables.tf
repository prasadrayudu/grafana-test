/*
#-------------------------------------------------
#                  Variables
#-------------------------------------------------
variable "env" {
  description = "AWS deployment environment"
  type        = string
  default     = "dev"
} 
*/

variable "grafana_contact_point_name" {
  description = "grafana contact point name slack or gmail"
  type        = string
  default     = "mlops-alerts"
}

variable "grafana_url" {
  description = "The URL of the Grafana instance."
}

variable "grafana_auth_token" {
  description = "The authentication token for Grafana."
}

variable "slack_webhook_url" {
  description = "The URL of the Grafana instance."
  type        = string
}

variable "slack_text_template" {
  type    = string
  default = <<EOT
{{ len .Alerts.Firing }} alerts are firing!

Alert summaries:
{{ range .Alerts.Firing }}
{{ template "Alert Instance Template" . }}
{{ end }}
EOT
}

variable "grafana_message_template_name" {
  description = "grafana message template name"
  type        = string
  default     = "mlops-alerts-dev"
}

variable "grafana_message_template" {
  type    = string
  default = <<EOT
{{ define "Alert Instance Template" }}
Firing: {{ .Labels.alertname }}
Silence: {{ .SilenceURL }}
{{ end }}
EOT
}

#notification policy
# variables.tf
/*
variable "notification_policies" {
  type = map(object({
    group_by        = list(string)
    contact_point   = string
    group_wait      = string
    group_interval  = string
    repeat_interval = string
    policies = list(object({
      matcher = map(object({
        label = string
        match = string
        value = string
      }))
      group_by      = list(string)
      contact_point = string
      mute_timings  = list(string)
      policies = list(object({
        matcher = map(object({
          label = string
          match = string
          value = string
        }))
        group_by      = list(string)
        contact_point = string
      }))
    }))
  }))

  default = {
    my_policy = {
      group_by        = ["alertname"]
      contact_point   = "mlops-dev-alerts"
      group_wait      = "45s"
      group_interval  = "6m"
      repeat_interval = "3h"
      policies = [
        {
          matcher = {
            label = "a"
            match = "="
            value = "b"
          }
          group_by      = ["label1"]
          contact_point = "mlops-dev-alerts"
          mute_timings  = ["My Mute Timing"]
          policies = [
            {
              matcher = {
                label = "a"
                match = "="
                value = "b"
              }
              group_by      = ["label2"]
              contact_point = "mlops-dev-alerts"
            }
          ]
        }
      ]
    }
  }
}
*/

variable "mute_timing_name" {
  type        = string
  description = "The name of the mute timing."
  default     = "My Mute Timing"
}

variable "mute_timing_start_time" {
  type        = string
  description = "The start time for the mute timing intervals."
  default     = "04:56"
}

variable "mute_timing_end_time" {
  type        = string
  description = "The end time for the mute timing intervals."
  default     = "14:17"
}

variable "mute_timing_weekdays" {
  type        = list(string)
  description = "The weekdays for the mute timing intervals."
  default     = ["saturday", "sunday", "tuesday:thursday"]
}

variable "mute_timing_months" {
  type        = list(string)
  description = "The months for the mute timing intervals."
  default     = ["january:march", "12"]
}

variable "mute_timing_years" {
  type        = list(string)
  description = "The years for the mute timing intervals."
  default     = ["2025:2027"]
}

variable "rule_folder_title" {
  type        = string
  description = "The title of the Grafana folder."
  default     = "Mlops Rule Folder"
}

variable "rule_group_name" {
  type        = string
  description = "The name of the Grafana rule group."
  default     = "mlops-alerts"
}

variable "rule_group_interval_seconds" {
  type        = number
  description = "The interval in seconds for the rule group."
  default     = 60
}

variable "rule_group_org_id" {
  type        = number
  description = "The organization ID for the rule group."
  default     = 1
}

# You can also define separate input variables for each part of the nested "rule" block if required.
# For simplicity, I'll use the whole "rule" block as a single input variable.
variable "rule_group_rule" {
  type = list(object({
    name      = string
    condition = string
    for       = string
    data = list(object({
      ref_id              = string
      relative_time_range = map(number)
      datasource_uid      = string
      model               = string
    }))
  }))
  description = "The list of rules in the rule group."
  default = [
    {
      name      = "Critical components down"
      condition = "C"
      for       = "0s"
      data = [
        {
          ref_id = "A"
          relative_time_range = {
            from = 600
            to   = 0
          }
          datasource_uid = "grafanacloud-prasadrayudu93-prom"
          model          = <<EOT
{"intervalMs":1000,"maxDataPoints":43200,"refId":"A"}
EOT
        },
        {
          datasource_uid = "__expr__"
          model          = <<EOT
{"conditions":[{"evaluator":{"params":[0,0],"type":"gt"},"operator":{"type":"and"},"query":{"params":["A"]},"reducer":{"params":[],"type":"last"},"type":"avg"}],"datasource":{"name":"Expression","type":"__expr__","uid":"__expr__"},"expression":"A","hide":false,"intervalMs":1000,"maxDataPoints":43200,"reducer":"last","refId":"B","type":"reduce"}
EOT
          ref_id         = "B"
          relative_time_range = {
            from = 0
            to   = 0
          }
        },
        {
          datasource_uid = "__expr__"
          ref_id         = "C"
          relative_time_range = {
            from = 0
            to   = 0
          }
          model = <<EOT
{"expression":"$B > 70","type":"math","refId":"C"}
EOT
        },
      ]
    },
  ]
}

# grafana notification policy variables
variable "notification_policy_group_by" {
  type    = list(string)
  default = ["alertname"]
}

/*
variable "notification_policy_contact_point" {
  type = string
}*/

variable "notification_policy_group_wait" {
  type    = string
  default = "45s"
}

variable "notification_policy_group_interval" {
  type    = string
  default = "6m"
}

variable "notification_policy_repeat_interval" {
  type    = string
  default = "3h"
}

variable "notification_policy_policy_matcher" {
  type = map(string)
  default = {
    label = "a"
    match = "="
    value = "b"
  }
}

variable "notification_policy_sublabel" {
  type    = string
  default = "sublabel"
}

variable "notification_policy_subvalue" {
  type    = string
  default = "subvalue"
}
