# aws-terraform-cloudwatch\_alarm

This module deploys a customized CloudWatch Alarm, for use in generating customer notifications or Rackspace support tickets.

## Basic Usage

```HCL
module "alarm" {
 source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.4"

 alarm_description        = "High CPU usage."
 comparison_operator      = "GreaterThanThreshold"
 customer_alarms_enabled  = true
 evaluation_periods       = 5
 metric_name              = "CPUUtilization"
 notification_topic       = [var.notification_topic]
 name                     = "MyCloudWatchAlarm"
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

## Terraform 0.12 upgrade

There should be no changes required to move from previous versions of this module to version 0.12.0 or higher.
## Module variables

The following module variables changes have occurred:

#### Deprecations
- `alarm_name` - marked for deprecation as it no longer meets our style guide standards.

#### Additions
- `name` - introduced as a replacement for `alarm_name` to better align with our style guide standards.

#### Removals
- None

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.7.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| alarm\_count | The number of alarms to create. | `number` | `1` | no |
| alarm\_description | The description for the alarm. | `string` | `""` | no |
| alarm\_name | The descriptive name for the alarm. This name must be unique within the user's AWS account. [**Deprecated** in favor of `name`]. It will be removed in future releases. `name` supercedes the `alarm_name`. Either `name` or `alarm_name` **must** contain a non-default value. | `string` | `""` | no |
| comparison\_operator | The arithmetic operation to use when comparing the specified Statistic and Threshold. The specified Statistic value is used as the first operand. Either of the following is supported: GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold, LessThanOrEqualToThreshold. | `string` | n/a | yes |
| customer\_alarms\_cleared | Specifies whether alarms will notify customers when returning to an OK status. | `bool` | `false` | no |
| customer\_alarms\_enabled | Specifies whether alarms will notify customers.  Automatically enabled if rackspace\_managed is set to false | `bool` | `false` | no |
| dimensions | The list of dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here. | `list(map(string))` | n/a | yes |
| evaluation\_periods | The number of periods over which data is compared to the specified threshold. | `number` | n/a | yes |
| metric\_name | The name for the alarm's associated metric. See https://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/CW_Support_For_AWS.html for supported metrics. | `string` | n/a | yes |
| name | The descriptive name for the alarm. This name must be unique within the user's AWS account. `name` supercedes the deprecated `alarm_name`. Either `name` or `alarm_name` **must** contain a non-default value. | `string` | `""` | no |
| name\_suffixes | Used to better distinguish similar alarms by replace 001 etc with given suffix. | `list(string)` | `[]` | no |
| namespace | The namespace for the alarm's associated metric. See https://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/aws-namespaces.html for the list of namespaces. | `string` | n/a | yes |
| notification\_topic | List of SNS Topic ARNs to use for customer notifications. | `list(string)` | `[]` | no |
| period | The period in seconds over which the specified statistic is applied. | `number` | `60` | no |
| rackspace\_alarms\_enabled | Specifies whether alarms will create a Rackspace ticket.  Ignored if rackspace\_managed is set to false | `bool` | `false` | no |
| rackspace\_managed | Boolean parameter controlling if instance will be fully managed by Rackspace support teams, created CloudWatch alarms that generate tickets, and utilize Rackspace managed SSM documents. | `bool` | `true` | no |
| severity | The desired severity of the created Rackspace ticket.  Supported values include: standard, urgent, emergency | `string` | `"standard"` | no |
| statistic | The statistic to apply to the alarm's associated metric. Either of the following is supported: SampleCount, Average, Sum, Minimum, Maximum | `string` | `"Average"` | no |
| threshold | The value against which the specified statistic is compared. [**Deprecated** in favor of `name`]. `thresholds` supercedes the depreciated `threshold`. Either `name` or `alarm_name` **must** contain a non-default value. | `string` | n/a | yes |
| thresholds | The values against which the specified statistic is compared per alarm. `thresholds` supercedes the depreciated `threshold`. Either `name` or `alarm_name` **must** contain a non-default value. | `list(string)` | `[]` | no |
| treat\_missing\_data | Sets how this alarm is to handle missing data points. The following values are supported: missing, ignore, breaching and notBreaching. Defaults to missing | `string` | `"missing"` | no |
| unit | The unit for the alarm's associated metric | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| alarm\_id | List of created alarm names |

