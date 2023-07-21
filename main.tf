#------------------------------------------------------
#         Provision contact points and templates
#------------------------------------------------------
resource "grafana_contact_point" "mlops-dev-alerts" {
  name = var.grafana_contact_point_name

  slack {
    url  = var.slack_webhook_url
    text = var.slack_text_template
  }
}

#------------------------------------------------------
#         Provision grafana message template
#------------------------------------------------------

resource "grafana_message_template" "my_alert_template" {
  name = var.grafana_message_template_name
  template = var.grafana_message_template 
}

#------------------------------------------------------
#         Provision grafana_notification_policy
#------------------------------------------------------


  resource "grafana_notification_policy" "my_policy" {
  for_each = var.notification_policies

  group_by      = each.value.group_by
  contact_point = each.value.contact_point

  group_wait      = each.value.group_wait
  group_interval  = each.value.group_interval
  repeat_interval = each.value.repeat_interval

  policy {
    dynamic "matcher" {
      for_each = each.value.policies[0].matcher
      content {
        label = matcher.value.label
        match = matcher.value.match
        value = matcher.value.value
      }
    }

    group_by      = each.value.policies[0].group_by
    contact_point = each.value.policies[0].contact_point

    mute_timings = each.value.policies[0].mute_timings

    policy {
      dynamic "matcher" {
        for_each = each.value.policies[0].policies[0].matcher
        content {
          label = matcher.value.label
          match = matcher.value.match
          value = matcher.value.value
        }
      }

      group_by      = each.value.policies[0].policies[0].group_by
      contact_point = each.value.policies[0].policies[0].contact_point
    }
  }
}

#------------------------------------------------------
#         Provision grafana_mute_timing
#------------------------------------------------------

resource "grafana_mute_timing" "my_mute_timing" {
  name = var.mute_timing_name

  intervals {
    times {
      start = var.mute_timing_start_time
      end   = var.mute_timing_end_time
    }
    weekdays = var.mute_timing_weekdays
    months   = var.mute_timing_months
    years    = var.mute_timing_years
  }
}

#------------------------------------------------------
#         Provision grafana_data_source
#------------------------------------------------------

#resource "grafana_data_source" "testdata_datasource" {
#  name = "TestData"
#  type = "testdata"
#}

#------------------------------------------------------
#         Provision grafana_folder
#------------------------------------------------------

resource "grafana_folder" "rule_folder" {
  title = var.rule_folder_title
}

#------------------------------------------------------
#         Provision grafana_rule_group
#------------------------------------------------------

# Read the alert_rule.json file
locals {
  alert_rules = jsondecode(file("${path.module}/alert_rules.json"))
}

# Create grafana_rule_group resources dynamically
resource "grafana_rule_group" "my_rule_group" {
  for_each = local.alert_rules

  name             = each.key
  folder_uid       = grafana_folder.rule_folder.uid
  interval_seconds = 60
  org_id           = 1

  dynamic "rule" {
    for_each = each.value["policies"]

    content {
      name      = rule.value["matcher"]["label"]
      condition = rule.value["matcher"]["match"]
      for       = rule.value["matcher"]["value"]

      dynamic "data" {
        for_each = rule.value["policies"]

        content {
          ref_id = data.value["matcher"]["label"]

          dynamic "relative_time_range" {
            for_each = data.value["group_by"]

            content {
              from = 600
              to   = 0
            }
          }

          datasource_uid = "grafanacloud-prasadrayudu93-prom"

          model = jsonencode({
            intervalMs    = 1000
            maxDataPoints = 43200
            refId         = data.value["matcher"]["label"]
          })
        }
      }
    }
  }
}

/*
resource "grafana_rule_group" "my_rule_group" {
  name             = "mlops-alerts"
  folder_uid       = grafana_folder.rule_folder.uid
  interval_seconds = 60
  org_id           = 1

  dynamic "rule" {
    for_each = jsondecode(file("${path.module}/alert_rules.json"))

    content {
      name      = rule.value.name
      condition = rule.value.condition
      for       = rule.value.for

      dynamic "data" {
        for_each = rule.value.data

        content {
          ref_id              = data.value.ref_id
          relative_time_range = data.value.relative_time_range
          datasource_uid      = data.value.datasource_uid
          model               = jsonencode(data.value.model)
        }
      }
    }
  }
}


/*
resource "grafana_rule_group" "my_rule_group" {
  name             = "mlops-alerts"
  folder_uid       = grafana_folder.rule_folder.uid
  interval_seconds = 60
  org_id           = 1

  rule {
    name      = "Critical components down"
    condition = "C"
    for       = "0s"

    // Query the datasource.
    data {
      ref_id = "A"
      relative_time_range {
        from = 600
        to   = 0
      }
     //  datasource_uid = grafana_data_source.testdata_datasource.uid
      datasource_uid = "grafanacloud-prasadrayudu93-prom"
      // `model` is a JSON blob that sends datasource-specific data.
      // It's different for every datasource. The alert's query is defined here.
      model = jsonencode({
        intervalMs    = 1000
        maxDataPoints = 43200
        refId         = "A"
      })
    }

    // The query was configured to obtain data from the last 60 seconds. Let's alert on the average value of that series using a Reduce stage.
    data {
      datasource_uid = "__expr__"
      // You can also create a rule in the UI, then GET that rule to obtain the JSON.
      // This can be helpful when using more complex reduce expressions.
      model  = <<EOT
{"conditions":[{"evaluator":{"params":[0,0],"type":"gt"},"operator":{"type":"and"},"query":{"params":["A"]},"reducer":{"params":[],"type":"last"},"type":"avg"}],"datasource":{"name":"Expression","type":"__expr__","uid":"__expr__"},"expression":"A","hide":false,"intervalMs":1000,"maxDataPoints":43200,"reducer":"last","refId":"B","type":"reduce"}
EOT
      ref_id = "B"
      relative_time_range {
        from = 0
        to   = 0
      }
    }

    // Now, let's use a math expression as our threshold.
    // We want to alert when the value of stage "B" above exceeds 70.
    data {
      datasource_uid = "__expr__"
      ref_id         = "C"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({
        expression = "$B > 70"
        type       = "math"
        refId      = "C"
      })
    }
  }
}
/*
resource "grafana_rule_group" "my_rule_group" {
  name             = "mlops-alerts"
  folder_uid       = grafana_folder.rule_folder.uid
  interval_seconds = 60
  org_id           = 1

  rule {
    name      = "Critical components down"
    condition = "C"
    for       = "0s"

    // Query the datasource.
    data {
      ref_id = "A"
      relative_time_range {
        from = 600
        to   = 0
      }
     //  datasource_uid = grafana_data_source.testdata_datasource.uid
      datasource_uid = "grafanacloud-prasadrayudu93-prom"
      // `model` is a JSON blob that sends datasource-specific data.
      // It's different for every datasource. The alert's query is defined here.
      model = jsonencode({
        intervalMs    = 1000
        maxDataPoints = 43200
        refId         = "A"
      })
    }

    // The query was configured to obtain data from the last 60 seconds. Let's alert on the average value of that series using a Reduce stage.
    data {
      datasource_uid = "__expr__"
      // You can also create a rule in the UI, then GET that rule to obtain the JSON.
      // This can be helpful when using more complex reduce expressions.
      model  = <<EOT
{"conditions":[{"evaluator":{"params":[0,0],"type":"gt"},"operator":{"type":"and"},"query":{"params":["A"]},"reducer":{"params":[],"type":"last"},"type":"avg"}],"datasource":{"name":"Expression","type":"__expr__","uid":"__expr__"},"expression":"A","hide":false,"intervalMs":1000,"maxDataPoints":43200,"reducer":"last","refId":"B","type":"reduce"}
EOT
      ref_id = "B"
      relative_time_range {
        from = 0
        to   = 0
      }
    }

    // Now, let's use a math expression as our threshold.
    // We want to alert when the value of stage "B" above exceeds 70.
    data {
      datasource_uid = "__expr__"
      ref_id         = "C"
      relative_time_range {
        from = 0
        to   = 0
      }
      model = jsonencode({
        expression = "$B > 70"
        type       = "math"
        refId      = "C"
      })
    }
  }
}

*/

/*

resource "grafana_alert" "instance_down" {
  rule_group_id = grafana_rule_group.rule_folder.id
  name          = "InstanceDown"

  condition {
    query = "up == 0"
    evaluator {
      type     = "for"
      duration = "5m"
    }
  }

  labels = {
    severity = "page"
  }

  annotations = {
    summary     = "Instance {{ $labels.instance }} down"
    description = "{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 5 minutes."
  }
}

resource "grafana_alert" "high_request_latency" {
  rule_group_id = grafana_rule_group.rule_folder.id
  name          = "APIHighRequestLatency"

  condition {
    query = "api_http_request_latencies_second{quantile=\"0.5\"} > 1"
    evaluator {
      type     = "for"
      duration = "10m"
    }
  }

  annotations = {
    summary     = "High request latency on {{ $labels.instance }}"
    description = "{{ $labels.instance }} has a median request latency above 1s (current value: {{ $value }}s)"
  }
}
*/


