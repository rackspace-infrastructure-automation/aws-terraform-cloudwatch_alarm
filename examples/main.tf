terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = "~> 2.7"
  region  = "us-west-2"
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=v0.12.1"

  name = "EC2-AR-BaseNetwork-Test1"
}

module "customer_notifications" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sns//?ref=v0.12.1"

  name = "my-notification-topic"
}

module "ec2_ar1" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ec2_autorecovery?ref=v0.12.4"

  ec2_os          = "amazon2"
  instance_type   = "t2.micro"
  name            = "test_amazon"
  security_groups = [module.vpc.default_sg]
  subnets         = module.vpc.private_subnets
}

module "ec2_ar2" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ec2_autorecovery?ref=v0.12.4"

  ec2_os          = "ubuntu16"
  instance_count  = 2
  instance_type   = "t2.micro"
  name            = "test_ubuntu"
  security_groups = [module.vpc.default_sg]
  subnets         = module.vpc.private_subnets
}

######################################
# CWAlarm to create Rackspace Ticket #
######################################
module "ar1_cpu_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.4"

  alarm_description        = "High CPU Usage on AR1."
  name                     = "CPUAlarmHigh-AR1"
  comparison_operator      = "GreaterThanThreshold"
  evaluation_periods       = 10
  metric_name              = "CPUUtilization"
  namespace                = "AWS/EC2"
  period                   = 60
  rackspace_alarms_enabled = true
  severity                 = "emergency"
  statistic                = "Average"
  threshold                = 90

  dimensions = [
    {
      InstanceId = element(module.ec2_ar1.ar_instance_id_list, 0)
    },
  ]
}

##############################
# CWAlarm to notify customer #
##############################
module "ar1_network_out_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.4"

  alarm_description       = "High Outbound Network traffic > 1MBps."
  name                    = "NetworkOutAlarmHigh-AR1"
  customer_alarms_enabled = true
  comparison_operator     = "GreaterThanThreshold"
  evaluation_periods      = 10
  metric_name             = "NetworkOut"
  namespace               = "AWS/EC2"
  notification_topic      = [module.customer_notifications.topic_arn]
  period                  = 60
  statistic               = "Average"
  threshold               = 60000000

  dimensions = [
    {
      InstanceId = element(module.ec2_ar1.ar_instance_id_list, 0)
    },
  ]
}

########################################
# Create alarms for multiple resources #
########################################
data "null_data_source" "alarm_dimensions" {
  count = 2

  inputs = {
    InstanceId = element(module.ec2_ar2.ar_instance_id_list, count.index)
    device     = "xvda1"
    fstype     = "ext4"
    path       = "/"
  }
}

module "ar2_disk_usage_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.4"

  alarm_count              = "2"
  alarm_description        = "High Disk usage."
  name                     = "HighDiskUsageAlarm-AR2"
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  dimensions               = data.null_data_source.alarm_dimensions.*.outputs
  evaluation_periods       = 30
  metric_name              = "disk_used_percent"
  namespace                = "System/Linux"
  period                   = 60
  rackspace_alarms_enabled = true
  severity                 = "standard"
  statistic                = "Average"
  threshold                = 80
}
