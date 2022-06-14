locals {
  tool_list_path = "${abspath(path.root)}/tool-list.yml"
  tool_list_exist = fileexists(local.tool_list_path)
  repos = concat(yamldecode(local.tool_list_exist ? file(local.tool_list_path) : data.local_file.tool_list[0].content)["tools"], var.additional_repos)
  galaxy_repositories = galaxy_repository.repositories
}

resource "docker_image" "irida" {
  count = local.tool_list_exist ? 0 : 1
  name = "${local.irida_image}:${var.image_tag}"
}

resource "docker_container" "tool_list" {
  count = local.tool_list_exist ? 0 : 1
  image = docker_image.irida[0].latest
  name = "irida-get-tool-list${local.name_suffix}"
  restart = "no"
  must_run = false
  attach = true
  command = ["cp", "${local.config_dir}/tool-list.yml", "/mnt/tool-list.yml"]
  mounts {
    source = abspath(path.root)
    target = "/mnt"
    type = "bind"
  }
}

data "local_file" "tool_list" {
  count = local.tool_list_exist ? 0 : 1
  depends_on = [docker_container.tool_list[0]]
  filename = local.tool_list_path
}

resource "galaxy_repository" "repositories" {
  # Deduplicate repos using https://www.terraform.io/docs/language/expressions/for.html#grouping-results
  for_each = { for k, v in zipmap([for repo in local.repos: "${regex("(?:https?://)?([^/]+)", repo.tool_shed_url)[0]}/repos/${repo.owner}/${repo.name}/${repo.revisions[0]}"], local.repos): k => v... }
  tool_shed = regex("(?:https?://)?([^/]+)", each.value.0.tool_shed_url)[0]
  owner = each.value.0.owner
  name = each.value.0.name
  changeset_revision = each.value.0.revisions[0]
}