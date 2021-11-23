# aws-terraform-cloudwatch\_alarm  
This module deploys a customized CloudWatch Alarm, for use in generating customer notifications or Rackspace support tickets.

## Basic Usage

```
module "alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.0.2"

  alarm_description        = "High CPU usage."
  alarm_name               = "MyCloudWatchAlarm"
  comparison_operator      = "GreaterThanThreshold"
  customer_alarms_enabled  = true
  evaluation_periods       = 5
  metric_name              = "CPUUtilization"
  notification_topic       = ["${var.notification_topic}"]
  namespace                = "AWS/EC2"
  period                   = 60
  rackspace_alarms_enabled = true
  rackspace_managed        = true
  severity                 = "urgent"
  statistic                = "Average"
  threshold                = 90

  dimension {
    InstanceId = "i-123456"
  }
}
```

Full working references are available at [examples](examples)

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) |
| [aws_cloudwatch_metric_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) |
| [aws_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alarm\_count | The number of alarms to create. | `string` | `1` | no |
| alarm\_description | The description for the alarm. | `string` | `""` | no |
| alarm\_name | The descriptive name for the alarm. This name must be unique within the user's AWS account | `string` | n/a | yes |
| comparison\_operator | The arithmetic operation to use when comparing the specified Statistic and Threshold. The specified Statistic value is used as the first operand. Either of the following is supported: GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold, LessThanOrEqualToThreshold. | `string` | n/a | yes |
| customer\_alarms\_cleared | Specifies whether alarms will notify customers when returning to an OK status. | `string` | `false` | no |
| customer\_alarms\_enabled | Specifies whether alarms will notify customers.  Automatically enabled if rackspace\_managed is set to false | `string` | `false` | no |
| dimensions | The list of dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here. | `list` | n/a | yes |
| evaluation\_periods | The number of periods over which data is compared to the specified threshold. | `string` | n/a | yes |
| metric\_name | The name for the alarm's associated metric. See https://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/CW_Support_For_AWS.html for supported metrics. | `string` | n/a | yes |
| namespace | The namespace for the alarm's associated metric. See https://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/aws-namespaces.html for the list of namespaces. | `string` | n/a | yes |
| notification\_topic | List of SNS Topic ARNs to use for customer notifications. | `list` | `[]` | no |
| period | The period in seconds over which the specified statistic is applied. | `string` | `60` | no |
| rackspace\_alarms\_enabled | Specifies whether alarms will create a Rackspace ticket.  Ignored if rackspace\_managed is set to false | `string` | `false` | no |
| rackspace\_managed | Boolean parameter controlling if instance will be fully managed by Rackspace support teams, created CloudWatch alarms that generate tickets, and utilize Rackspace managed SSM documents. | `string` | `true` | no |
| severity | The desired severity of the created Rackspace ticket.  Supported values include: standard, urgent, emergency | `string` | `"standard"` | no |
| statistic | The statistic to apply to the alarm's associated metric. Either of the following is supported: SampleCount, Average, Sum, Minimum, Maximum | `string` | `"Average"` | no |
| threshold | The value against which the specified statistic is compared. | `string` | n/a | yes |
| treat\_missing\_data | Sets how this alarm is to handle missing data points. The following values are supported: missing, ignore, breaching and notBreaching. Defaults to missing | `string` | `"missing"` | no |
| unit | The unit for the alarm's associated metric | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| alarm\_id | List of created alarm names |
