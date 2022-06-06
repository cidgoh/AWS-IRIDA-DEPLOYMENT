# Galaxy Deployment

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_docker"></a> [docker](#provider\_docker) | n/a |
| <a name="provider_galaxy"></a> [galaxy](#provider\_galaxy) | n/a |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_repos"></a> [additional\_repos](#input\_additional\_repos) | Additional repositories to install to Galaxy | <pre>list(object({<br>    name          = string<br>    owner         = string<br>    tool_shed_url = string<br>    revisions     = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Application container name | `string` | `null` | no |
| <a name="input_base_url"></a> [base\_url](#input\_base\_url) | The externally visible URL for accessing this instance of IRIDA. This key is used by the e-mailer when sending out e-mail notifications (password resets, for example) and embeds this URL directly in the body of the e-mail. | `string` | `""` | no |
| <a name="input_custom_pages"></a> [custom\_pages](#input\_custom\_pages) | Custom pages, keyed on file name | `map` | `{}` | no |
| <a name="input_data_dir"></a> [data\_dir](#input\_data\_dir) | Path to user data within container | `string` | `null` | no |
| <a name="input_db_conf"></a> [db\_conf](#input\_db\_conf) | Database configuration overrides | <pre>object({<br>    scheme = string<br>    host   = string<br>    name   = string<br>    user   = string<br>    pass   = string<br>  })</pre> | `null` | no |
| <a name="input_db_data_volume_name"></a> [db\_data\_volume\_name](#input\_db\_data\_volume\_name) | Database volume name | `string` | `null` | no |
| <a name="input_db_image"></a> [db\_image](#input\_db\_image) | MariaDB image name (Ignored if destination provides hosted database) | `string` | `"mariadb"` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Database container name | `string` | `null` | no |
| <a name="input_debug"></a> [debug](#input\_debug) | Enabling will put the deployment into a mode suitable for debugging | `bool` | `false` | no |
| <a name="input_front_replicates"></a> [front\_replicates](#input\_front\_replicates) | Number of replicate front end instances | `number` | `1` | no |
| <a name="input_galaxy_api_key"></a> [galaxy\_api\_key](#input\_galaxy\_api\_key) | The API key of an account to run workflows in Galaxy. This does not have to be an administrator account. | `string` | n/a | yes |
| <a name="input_galaxy_user_email"></a> [galaxy\_user\_email](#input\_galaxy\_user\_email) | The email address of an account to run workflows in Galaxy | `string` | n/a | yes |
| <a name="input_hide_workflows"></a> [hide\_workflows](#input\_hide\_workflows) | A list of workflow types to disable from display in the web interface | `list(string)` | `[]` | no |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | Tag for irida\_app image | `string` | `"latest"` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Unique deployment instance identifier | `string` | `""` | no |
| <a name="input_irida_config"></a> [irida\_config](#input\_irida\_config) | settings to override in irida.conf | `map(string)` | `{}` | no |
| <a name="input_irida_image"></a> [irida\_image](#input\_irida\_image) | IRIDA application image name | `string` | `null` | no |
| <a name="input_mail_config"></a> [mail\_config](#input\_mail\_config) | n/a | <pre>object({<br>    host     = string<br>    port     = number<br>    username = string<br>    password = string<br>    from     = string<br>  })</pre> | `null` | no |
| <a name="input_plugins"></a> [plugins](#input\_plugins) | Set of URLs to wars to download into plugins folder | `set(string)` | `[]` | no |
| <a name="input_processing_replicates"></a> [processing\_replicates](#input\_processing\_replicates) | Number of replicate processing instances | `number` | `1` | no |
| <a name="input_tmp_dir"></a> [tmp\_dir](#input\_tmp\_dir) | Path to mount temporary space into container | `string` | `null` | no |
| <a name="input_user_data_volume_name"></a> [user\_data\_volume\_name](#input\_user\_data\_volume\_name) | User data volume name | `string` | `null` | no |
| <a name="input_web_config"></a> [web\_config](#input\_web\_config) | settings to override in web.conf | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_conf"></a> [db\_conf](#output\_db\_conf) | n/a |
| <a name="output_galaxy_repositories"></a> [galaxy\_repositories](#output\_galaxy\_repositories) | n/a |

## Resources

| Name | Type |
|------|------|
| [docker_container.tool_list](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container) | resource |
| [docker_image.irida](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image) | resource |
| [galaxy_repository.repositories](https://registry.terraform.io/providers/brinkmanlab/galaxy/latest/docs/resources/repository) | resource |
| [random_password.db_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [local_file.tool_list](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
<!-- END_TF_DOCS -->