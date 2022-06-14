locals {
  namespace = var.namespace != null ? var.namespace : kubernetes_namespace.instance[0]
  galaxy_repositories = module.k8s.galaxy_repositories
  waf_lb_anotations = var.enable_waf? {
   "alb.ingress.kubernetes.io/wafv2-acl-arn": aws_wafv2_web_acl.waf.arn
    "service.beta.kubernetes.io/aws-load-balancer-type" : "alb"
  }: {}
}

resource "kubernetes_namespace" "instance" {
  count = var.namespace == null ? 1 : 0
  metadata {
    name = local.instance
  }
}

module "k8s" {
  source                = "../k8s"
  depends_on = [kubernetes_service.irida_db]
  irida_image           = var.irida_image
  image_tag             = var.image_tag
  db_conf               = local.db_conf
  instance              = local.instance
  base_url              = local.base_url
  galaxy_api_key        = var.galaxy_api_key
  galaxy_user_email     = var.galaxy_user_email
  mail_config           = var.mail_config
  irida_config          = var.irida_config
  web_config            = var.web_config
  app_name              = local.app_name
  db_name               = local.db_name
  data_dir              = local.data_dir
  tmp_dir               = local.tmp_dir
  user_data_volume_name = local.user_data_volume_name
  db_data_volume_name   = local.db_data_volume_name
  claim_name            = var.claim_name
  hide_workflows        = var.hide_workflows
  front_replicates      = var.front_replicates
  processing_replicates = var.processing_replicates
  debug                 = var.debug
  namespace             = local.namespace
  plugins               = var.plugins
  additional_repos      = var.additional_repos
  lb_annotations        = merge (var.lb_annotations, local.waf_lb_anotations)
  custom_pages          = var.custom_pages
}

resource "aws_wafv2_web_acl" "waf" {
  name  = "web-acl-association-example"
  scope = "REGIONAL"

  default_action {
    allow {}
  }
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 0
    statement {
      managed_rule_group_statement {
        name        = "AWS"
        vendor_name = "AWSManagedRulesCommonRuleSet"
      }
    }
    override_action {
      none {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }
#  rule {
#    name     = "AWSManagedRulesLinuxRuleSet"
#    priority = 1
#    statement {
#      managed_rule_group_statement {
#        name        = "AWS"
#        vendor_name = "AWSManagedRulesLinuxRuleSet"
#      }
#    }
#    override_action {
#      none {}
#    }
#    visibility_config {
#      cloudwatch_metrics_enabled = true
#      metric_name                = "AWSManagedRulesLinuxRuleSet"
#      sampled_requests_enabled   = true
#    }
#  }
#  rule {
#    name     = "AWSManagedRulesKnownBadInputsRuleSet"
#    priority = 2
#    statement {
#      managed_rule_group_statement {
#        name        = "AWS"
#        vendor_name = "AWSManagedRulesKnownBadInputsRuleSet"
#      }
#    }
#    override_action {
#      none {}
#    }
#    visibility_config {
#      cloudwatch_metrics_enabled = true
#      metric_name                = "AWSManagedRulesKnownBadInputsRuleSet"
#      sampled_requests_enabled   = true
#    }
#  }
#  rule {
#    name     = "AWSManagedRulesSQLiRuleSet"
#    priority = 3
#    statement {
#      managed_rule_group_statement {
#        name        = "AWS"
#        vendor_name = "AWSManagedRulesSQLiRuleSet"
#      }
#    }
#    override_action {
#      none {}
#    }
#    visibility_config {
#      cloudwatch_metrics_enabled = true
#      metric_name                = "AWSManagedRulesSQLiRuleSet"
#      sampled_requests_enabled   = true
#    }
#  }
#  rule {
#    name     = "AWSManagedRulesAdminProtectionRuleSet"
#    priority = 4
#    statement {
#      managed_rule_group_statement {
#        name        = "AWS"
#        vendor_name = "AWSManagedRulesAdminProtectionRuleSet"
#      }
#    }
#    override_action {
#      none {}
#    }
#    visibility_config {
#      cloudwatch_metrics_enabled = true
#      metric_name                = "AWSManagedRulesAdminProtectionRuleSet"
#      sampled_requests_enabled   = true
#    }
#  }
#  rule {
#    name     = "AWSManagedRulesAnonymousIpList"
#    priority = 4
#    statement {
#      managed_rule_group_statement {
#        name        = "AWS"
#        vendor_name = "AWSManagedRulesAnonymousIpList"
#      }
#    }
#    override_action {
#      none {}
#    }
#    visibility_config {
#      cloudwatch_metrics_enabled = true
#      metric_name                = "AWSManagedRulesAnonymousIpList"
#      sampled_requests_enabled   = true
#    }
#  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "irida-waf-metric"
    sampled_requests_enabled   = true
  }
}
