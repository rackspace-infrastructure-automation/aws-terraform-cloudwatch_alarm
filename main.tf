/**
 * # aws-terraform-cloudwatch_alarm
 *
 * This module deploys a customized CloudWatch Alarm, for use in generating customer notifications or Rackspace support tickets.
 *
 * ## Basic Usage
 *
 * ```HCL
 * module "alarm" {
 *  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"
 *
 *  alarm_description        = "High CPU usage."
 *  comparison_operator      = "GreaterThanThreshold"
 *  customer_alarms_enabled  = true
 *  evaluation_periods       = 5
 *  metric_name              = "CPUUtilization"
 *  notification_topic       = [var.notification_topic]
 *  name                     = "MyCloudWatchAlarm"
 *  namespace                = "AWS/EC2"
 *  period                   = 60
 *  rackspace_alarms_enabled = true
 *  rackspace_managed        = true
 *  severity                 = "urgent"
 *  statistic                = "Average"
 *  threshold                = 90
 *
 *  dimension {
 *    InstanceId = "i-123456"
 *  }
 * }
 * ```
 *
 * Full working references are available at [examples](examples)
 *
 * ## Terraform 0.12 upgrade
 *
 * There should be no changes required to move from previous versions of this module to version 0.12.0 or higher.
 * ## Module variables
*
* The following module variables changes have occurred:
*
* #### Deprecations
* - `alarm_name` - marked for deprecation as it no longer meets our style guide standards.
*
* #### Additions
* - `name` - introduced as a replacement for `alarm_name` to better align with our style guide standards.
*
* #### Removals
* - None
*/

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = ">= 2.7.0"
  }
}

locals {
  # favor name over alarm name if both are set
  alarm_name             = var.name != "" ? var.name : var.alarm_name
  rackspace_alarm_config = var.rackspace_alarms_enabled && var.rackspace_managed ? "enabled" : "disabled"
  customer_alarm_config  = var.customer_alarms_enabled || false == var.rackspace_managed ? "enabled" : "disabled"
  customer_ok_config     = var.customer_alarms_cleared && var.customer_alarms_enabled || false == var.rackspace_managed ? "enabled" : "disabled"

  rackspace_alarm_actions = {
    enabled  = [local.rackspace_sns_topic[var.severity]]
    disabled = []
  }

  customer_alarm_actions = {
    enabled  = compact(var.notification_topic)
    disabled = []
  }

  rackspace_sns_topic = {
    standard  = "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:rackspace-support-standard"
    urgent    = "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:rackspace-support-urgent"
    emergency = "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:rackspace-support-emergency"
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_cloudwatch_metric_alarm" "alarm" {
  count = var.alarm_count

  alarm_description   = var.alarm_description
  alarm_name          = var.alarm_count > 1 ? format("%v-%v", local.alarm_name, length(var.name_suffixes) == 0 ? format("%03d", count.index + 1) : var.name_suffixes[count.index]) : local.alarm_name
  comparison_operator = var.comparison_operator
  dimensions          = var.dimensions[count.index]
  evaluation_periods  = var.evaluation_periods
  metric_name         = var.metric_name
  namespace           = var.namespace
  period              = var.period
  statistic           = var.statistic
  threshold           = length(var.thresholds) == 0 ? var.threshold : var.thresholds[count.index]
  treat_missing_data  = var.treat_missing_data
  unit                = var.unit

  alarm_actions = concat(
    local.rackspace_alarm_actions[local.rackspace_alarm_config],
    local.customer_alarm_actions[local.customer_alarm_config],
  )

  ok_actions = concat(
    local.rackspace_alarm_actions[local.rackspace_alarm_config],
    local.customer_alarm_actions[local.customer_ok_config],
  )
}
