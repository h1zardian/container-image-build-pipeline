`tfm init`


`tfm apply --var-file=".tfvars" --auto-approve`


Update your kubeconfig file with the new EKS cluster details using the AWS CLI. Replace <cluster_name> with the actual name of your EKS cluster:

`aws eks --region <region> update-kubeconfig --name <cluster_name>`


Verify that your kubectl is now set to the new context:

`kubectl config get-contexts`


`helm install django-app-release . -f user-values.yaml`




To install:
`ansible-playbook helm-charts.yml -e "helm_action=install"`

To uninstall:
`ansible-playbook helm-charts.yml -e "helm_action=absent"`



To create an IAM OIDC identity provider for your cluster with eksctl

    Determine whether you have an existing IAM OIDC provider for your cluster.

    Retrieve your cluster's OIDC provider ID and store it in a variable. Replace my-cluster with your own value.


`export cluster_name=my-cluster`

`oidc_id=$(aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)`


Determine whether an IAM OIDC provider with your cluster's ID is already in your account.


`aws iam list-open-id-connect-providers | grep $oidc_id | cut -d "/" -f4`


If output is returned, then you already have an IAM OIDC provider for your cluster and you can skip the next step. If no output is returned, then you must create an IAM OIDC provider for your cluster.

Create an IAM OIDC identity provider for your cluster with the following command.

`eksctl utils associate-iam-oidc-provider --cluster $cluster_name --approve`



To create your Amazon EBS CSI plugin IAM role with eksctl

    Create an IAM role and attach the required AWS managed policy with the following command. Replace my-cluster with the name of your cluster. The command deploys an AWS CloudFormation stack that creates an IAM role and attaches the IAM policy to it. If your cluster is in the AWS GovCloud (US-East) or AWS GovCloud (US-West) AWS Regions, then replace arn:aws: with arn:aws-us-gov:.

```
eksctl create iamserviceaccount \
    --name ebs-csi-controller-sa \
    --namespace kube-system \
    --cluster my-cluster \
    --role-name AmazonEKS_EBS_CSI_DriverRole \
    --role-only \
    --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
    --approve
```


To add the Amazon EBS CSI add-on using eksctl

Run the following command. Replace my-cluster with the name of your cluster, 111122223333 with your account ID, and AmazonEKS_EBS_CSI_DriverRole with the name of the IAM role created earlier. If your cluster is in the AWS GovCloud (US-East) or AWS GovCloud (US-West) AWS Regions, then replace arn:aws: with arn:aws-us-gov:.

`eksctl create addon --name aws-ebs-csi-driver --cluster my-cluster --service-account-role-arn arn:aws:iam::111122223333:role/AmazonEKS_EBS_CSI_DriverRole --force`