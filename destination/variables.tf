locals {
  ansible = yamldecode(file("${path.module}/../../vars.yml"))

  app_name              = var.app_name != null ? var.app_name : local.ansible.containers.app.name
  db_name               = var.db_name != null ? var.db_name : local.ansible.containers.db.name
  data_dir              = var.data_dir != null ? var.data_dir : local.ansible.paths.data
  galaxy_name           = local.ansible.containers.galaxy.name
  reference_dir         = local.ansible.paths.reference
  sequences_dir         = local.ansible.paths.sequences
  output_dir            = local.ansible.paths.output
  assembly_dir          = local.ansible.paths.assembly
  config_dir            = local.ansible.paths.config
  tmp_dir               = local.ansible.paths.tmp
  app_dir               = local.ansible.paths.app
  user_data_volume_name = var.user_data_volume_name != null ? var.user_data_volume_name : local.ansible.volumes.user_data.name
  db_data_volume_name   = var.db_data_volume_name != null ? var.db_data_volume_name : local.ansible.volumes.db_data.name

  irida_image = var.irida_image != null ? var.irida_image : "brinkmanlab/${local.app_name}"
  irida_uid   = local.ansible.irida.uid
  irida_gid   = local.ansible.irida.gid

  name_suffix = var.instance == "" ? "" : "-${var.instance}"

  db_conf = var.db_conf != null ? var.db_conf : {
    scheme = "mysql"
    host   = local.db_name
    name   = "irida"
    user   = "irida"
    pass   = random_password.db_password[0].result
  }

  mail_config = var.mail_config != null ? var.mail_config : {
    host     = regex("(?m)^mail.*hostname=(?P<mail_name>[^ ]+)", file("${path.module}/../../inventory.ini")).mail_name
    port     = regex("(?m)^mail.*port=(?P<mail_port>[^ ]+)", file("${path.root}/../../inventory.ini")).mail_port
    username = ""
    password = ""
    from     = var.galaxy_user_email
  }

  profiles = {
    front      = ["web"]
    processing = ["processing"]
    singleton  = ["email", "analysis", "sync", "ncbi"]
  }

  replicates = {
    front      = var.front_replicates
    processing = var.processing_replicates
    singleton  = 1 # MUST ALWAYS BE 1
  }

  irida_config = join("\n", [for k, v in merge(local.ansible.irida.config, {
    "server.base.url"               = var.base_url
    "jdbc.url"                      = "jdbc:${local.db_conf.scheme}://${local.db_conf.host}/${local.db_conf.name}"
    "jdbc.username"                 = local.db_conf.user
    "jdbc.password"                 = local.db_conf.pass
    "galaxy.execution.apiKey"       = var.galaxy_api_key
    "galaxy.execution.email"        = var.galaxy_user_email
    "irida.workflow.types.disabled" = join(",", var.hide_workflows)
    "galaxy.execution.url"          = "http://${local.galaxy_name}/"
    "pipeline.plugin.path"          = "${local.data_dir}/plugins"
  }, var.irida_config) : "${k}=${v}"])

  web_config = join("\n", [for k, v in merge(local.ansible.irida.web, {
    "mail.server.host"     = local.mail_config.host
    "mail.server.port"     = local.mail_config.port
    "mail.server.email"    = local.mail_config.from
    "mail.server.username" = local.mail_config.username
    "mail.server.protocol" = "smtp"
  }, local.mail_config.password == "" ? {} : { "mail.server.password" = local.mail_config.password }, var.web_config) : "${k}=${v}"])

  plugin_curl_cmd = join(" && ", flatten(["cd ${local.data_dir}/plugins", [for url in var.plugins : "curl -O -L '${url}'"]]))
}

resource "random_password" "db_password" {
  count   = var.db_conf == null ? 1 : 0
  length  = 16
  special = false
}

variable "instance" {
  type        = string
  default     = ""
  description = "Unique deployment instance identifier"
}

variable "app_name" {
  type        = string
  default     = null
  description = "Application container name"
}

variable "db_name" {
  type        = string
  default     = null
  description = "Database container name"
}

variable "user_data_volume_name" {
  type        = string
  default     = null
  description = "User data volume name"
}

variable "db_data_volume_name" {
  type        = string
  default     = null
  description = "Database volume name"
}

variable "data_dir" {
  type        = string
  default     = null
  description = "Path to user data within container"
}

variable "tmp_dir" {
  type        = string
  default     = null
  description = "Path to mount temporary space into container"
}

variable "image_tag" {
  type        = string
  default     = "latest"
  description = "Tag for irida_app image"
}

variable "front_replicates" {
  type        = number
  default     = 1
  description = "Number of replicate front end instances"
}

variable "processing_replicates" {
  type        = number
  default     = 1
  description = "Number of replicate processing instances"
}

variable "base_url" {
  type        = string
  default     = ""
  description = "The externally visible URL for accessing this instance of IRIDA. This key is used by the e-mailer when sending out e-mail notifications (password resets, for example) and embeds this URL directly in the body of the e-mail."
}

variable "galaxy_api_key" {
  type        = string
  description = "The API key of an account to run workflows in Galaxy. This does not have to be an administrator account."
}

variable "galaxy_user_email" {
  type        = string
  description = "The email address of an account to run workflows in Galaxy"
}

variable "mail_config" {
  type = object({
    host     = string
    port     = number
    username = string
    password = string
    from     = string
  })
  default = null
}

variable "irida_config" {
  type        = map(string)
  default     = {}
  description = "settings to override in irida.conf"
}

variable "web_config" {
  type        = map(string)
  default     = {}
  description = "settings to override in web.conf"
}

variable "hide_workflows" {
  type        = list(string)
  default     = []
  description = "A list of workflow types to disable from display in the web interface"
}

variable "db_conf" {
  type = object({
    scheme = string
    host   = string
    name   = string
    user   = string
    pass   = string
  })
  default     = null
  description = "Database configuration overrides"
}

variable "irida_image" {
  type        = string
  default     = null
  description = "IRIDA application image name"
}

variable "db_image" {
  type        = string
  default     = "mariadb"
  description = "MariaDB image name (Ignored if destination provides hosted database)"
}

variable "debug" {
  type        = bool
  default     = false
  description = "Enabling will put the deployment into a mode suitable for debugging"
}

variable "plugins" {
  type        = set(string)
  default     = []
  description = "Set of URLs to wars to download into plugins folder"
}

variable "additional_repos" {
  type = list(object({
    name          = string
    owner         = string
    tool_shed_url = string
    revisions     = list(string)
  }))
  default     = []
  description = "Additional repositories to install to Galaxy"
}

variable "custom_pages" {
  default = {}
  description = "Custom pages, keyed on file name"
}