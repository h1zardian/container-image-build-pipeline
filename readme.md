<a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-purple.svg?labelColor=303030" /></a>
<br />

## About The Project

<div>
  <a href="https://raw.githubusercontent.com/h1zardian/container-image-build-pipeline/main/docs/build-pipeline.png">
  <img src="https://raw.githubusercontent.com/h1zardian/container-image-build-pipeline/main/docs/build-pipeline.png">
  </a>
</div>

</br>

> **Detailed Pipeline Workflow**
>
> 1. **Initiating the Development Environment**: The software developer accesses a specially prepared development environment. This virtual container has all the necessary tools, packages, and settings pre-configured to facilitate the creation of the software pipeline.
>
> 2. **Setting up the Build Server**: Through the use of a scripted process called an Ansible playbook, the developer commands the creation of a specialized server (buildah server) required for assembling the software components.
>
> 3. **Infrastructure Provisioning via Terraform**: Using a common automation tool named Terraform, the playbook provisions the necessary resources on Amazon Web Services (AWS), including computing servers.
>
> 4. **Connecting to AWS**: Terraform makes use of stored AWS credentials to access the cloud provider's resources, thereby allocating the necessary computing power and infrastructure.
>
> 5. **Configuring the Build Server**: Ansible further automates the setup by using Terraform's output to connect to the newly created server (EC2 instance) and installs the essential package (buildah).
>
> 6. **Storing Configuration Details**: The developer manually records specific server information within the project's GitHub repository for secure access and collaboration.
>
> 7. **Triggering the Build Process**: A new software version triggers an automated process (GitHub Actions workflow) that connects to the build server. This process includes obtaining a copy of the software code and executing the build instructions.
>
> 8. **Container Image Creation and Storage**: The build server crafts a container image and labels it with identifying tags. It then sends this image to Docker Hub, a centralized repository, for later retrieval.

## How to Use

Add the following secrets to the github repo
```python
DOCKER_HUB_AUTH      # base64 encoded dockerhub username and password (echo -n 'username:password' | base64)
DOCKER_HUB_USERNAME  # dockerhub username
EC2_HOST             # public dns or ip of the ec2 instance
EC2_SSH_KEY          # private key of the ec2 instance
EC2_USERNAME         # username of the ec2 instance (default: ubuntu)
```

Check if the aws access key is present in the `~/.aws/credentials` file. If not, create the access key for your IAM user and add it to the file.

Also create the ssh key-pair for the ec2 instance and add it to the `~/.ssh` folder or the ansible folder of the project directory.  
e.g: build-pipeline-ec2.key

Change the permission of the key-pair file to 600

```bash
chmod 600 build-pipeline-ec2.key
```

Check the `ansible.cfg` file and change the `private_key_file` to the key-pair file name.

Execute the ansible playbook
```bash
ansible-playbook playbooks/buildah-pipeline.yml
```

Check the terraform state of the `buildah_instance` and copy the `public_dns`
```bash
terraform state show aws_instance.buildah
```

Add the `public_dns` to github repo secrets as `EC2_HOST`.

Now you can make a commit to the repo to trigger the pipeline. And it will build the container image and push it to the DockerHub Registry.

### Destroy the Terraform Resources and GitHub Actions Workflow
To destroy the terraform provisioned resources, change directory to `terraform/buildah-server` and execute the following command
```bash
terraform destroy --auto-approve
```

And to disable the GitHub Actions workflow, go to the `Actions` tab of the repo and disable the workflow from there.  
docs link: [GitHub Workflow Docs](https://docs.github.com/en/enterprise-cloud@latest/actions/using-workflows/disabling-and-enabling-a-workflow?tool=webui).
