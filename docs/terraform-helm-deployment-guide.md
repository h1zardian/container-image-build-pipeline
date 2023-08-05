`tfm init`


`tfm apply --var-file=".tfvars" --auto-approve`


Update your kubeconfig file with the new EKS cluster details using the AWS CLI. Replace <cluster_name> with the actual name of your EKS cluster:

`aws eks --region <region> update-kubeconfig --name <cluster_name>`


Verify that your kubectl is now set to the new context:

`kubectl config get-contexts`


`helm install django-app-release . -f .secrets`