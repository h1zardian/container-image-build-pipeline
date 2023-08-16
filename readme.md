<a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-purple.svg?labelColor=303030" /></a>
<br />

## About The Project

<div>
  <a href="https://raw.githubusercontent.com/h1zardian/cluster-provisioning-pipeline/main/docs/build-pipeline.png">
  <img src="https://raw.githubusercontent.com/h1zardian/cluster-provisioning-pipeline/main/docs/build-pipeline.png">
  </a>
</div>

## How to Use

Add the following secrets to the github repo
```python
DOCKER_HUB_AUTH      # base64 encoded dockerhub username and password (echo -n 'username:password' | base64)
DOCKER_HUB_USERNAME  # dockerhub username
EC2_HOST             # public dns or ip of the ec2 instance
EC2_SSH_KEY          # private key of the ec2 instance
EC2_USERNAME         # username of the ec2 instance (default: ubuntu)
```

Add the ec2 key file in the ansible folder.  
e.g: build-pipeline-ec2.key

Change the permission of the key file to 600
```bash
$ chmod 600 build-pipeline-ec2.key
```
Check the `ansible.cfg` file and change the `private_key_file` to the key file name.

Execute the ansible playbook
```bash
$ ansible-playbook playbooks/buildah-pipeline.yml
```

Check the terraform state of the `buildah_instance` and copy the `public_dns`
```bash
$ terraform state show buildah_instance
```

Add the `public_dns` to github repo secrets as `EC2_HOST`.

Now you can make a commit to the repo to trigger the pipeline. And it will build the container image and push it to the DockerHub Registry.

**Destroy the Terraform Resources**  
To destroy the terraform provisioned resources, change directory to `terraform/buildah-server` and execute the following command
```bash
$ terraform destroy --auto-approve
```
