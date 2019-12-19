terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = "~> 2.2"
  region  = "us-west-2"
}

module "vpc" {
  source   = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=v0.0.6"
  vpc_name = "EC2-AR-BaseNetwork-Test1"
}

module "customer_notifications" {
  source     = "git@github.com:rackspace-infrastructure-automation/aws-terraform-sns//?ref=v0.0.2"
  topic_name = "my-notification-topic"
}

module "ec2_ar1" {
  source              = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ec2_autorecovery?ref=v0.0.9"
  ec2_os              = "amazon2"
  subnets             = module.vpc.private_subnets
  security_group_list = [module.vpc.default_sg]
  instance_type       = "t2.micro"
  resource_name       = "test_amazon"
}

module "ec2_ar2" {
  source              = "git@github.com:rackspace-infrastructure-automation/aws-terraform-ec2_autorecovery?ref=v0.0.9"
  ec2_os              = "ubuntu16"
  instance_count      = "2"
  subnets             = module.vpc.private_subnets
  security_group_list = [module.vpc.default_sg]
  instance_type       = "t2.micro"
  resource_name       = "test_ubuntu"
}

######################################
# CWAlarm to create Rackspace Ticket #
######################################
module "ar1_cpu_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.0.1"

  alarm_description        = "High CPU Usage on AR1."
  alarm_name               = "CPUAlarmHigh-AR1"
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
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.0.1"

  alarm_description       = "High Outbound Network traffic > 1MBps."
  alarm_name              = "NetworkOutAlarmHigh-AR1"
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
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.0.1"

  alarm_count              = "2"
  alarm_description        = "High Disk usage."
  alarm_name               = "HighDiskUsageAlarm-AR2"
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
