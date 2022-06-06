# IRIDA Container and deployment

The repository contains everything needed to build a container for IRIDA and deploy to a cloud resource.
Example deployments are provided in the `./deployment` folder for various destinations. For production use, it is
recommended to create your own deployment recipe using the terraform modules provided in `./desinations`. Terraform
is the deployment managment software used for all deployment destinations.

To install terraform, check that your systems package manager provides it or download it from [here](https://www.terraform.io/downloads.html).

IRIDAs default username and password is `admin` and `password1` respectively.

See the [module documentation](destinations/README.md) for more information on this deployments capabilities and customisability.

## Deploy to cloud

Several terraform destinations have been configured. Select one from the `./deployment/` folder that you wish to use.

### AWS

See [deployment/aws/](deployment/aws/) for instructions.

### Kubernetes

All cloud deployments include a dashboard server that provides administrative control of the cluster.
To access it, [install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) and run `kubectl proxy` in a separate terminal.
Visit [here](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login) to
access the dashboard.

To check the state of the cluster run `kubectl describe node`.
To restart a deployment run `kubectl rollout restart -n irida deployment <deployment name>`.

### Existing Kubernetes cluster

Configure the Kubernetes terraform provider and deploy the `./destinations/k8s` module.

### Existing Nomad cluster

Configure the Nomad terraform provider and deploy the `./destinations/nomad` module.

### Deployment

Terraform is used to deploy the various resources needed to run IRIDA to the cloud provider of choice.

* `./destinations` - Terraform modules responsible for deployment into the various providers
* `./deployment` - Usage examples for the destination modules
