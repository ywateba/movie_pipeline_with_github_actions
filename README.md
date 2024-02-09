# Movie Pipeline with github actions

This project showcases a pipeline with github actions for two applications :

    1. A frontend UI built written in Typescript, using the React framework

    2. A backend API written in Python using the Flask framework.

For each application you have 2 pipelines which performs 4 possibles steps:

    - lint
    - test
    - build of docker image and push on ECR
    - deploy on Kubernetes cluster

The continuous integration workflow with the first 3 steps , and Continuous deployment workflow with all steps.
Both Pipeline are triggered on push or pull request, on main branch if the app code  is modified, but can also be triggered manually.


## Project structure
 - backend : Backend app folder
 - frontend: frontend app folder
 - terraform: Iac folder to create cluster and ecr
 - .github/workflows : contains workflows

 Apps folder have a docker file and sub folder with kubernetes manifest to deploy

## Project requirements

To get started with the project you need :
- An aws account
- Following tools intalled on your machine:
    - Terraform
    - awscli
    - kubectl
    - docker


## Instructions


### Build infrastructure

This part assume you have awcli installed and configured on your machine

Go into terraform folder and run
 ```hcl
 terraform plan
 terraform apply

 ```
- Check the outputs and terraform state file to get user credentials.
- Check your aws account, you should have an eks cluster an 2 ecr repositories created


### Cluster access

To grant the github_action_user access to your cluster, run on your machine:

```bash
# to connect to the cluster
aws eks --region us-east-1 update-kubeconfig --name <cluster_name> --profile <your_aws_profile>

# to grant access to github-action-user
chmod +x ./init.sh
./init.sh
```
The aws profile must be the same used to create the cluster


### Github

- From project settings UI, add the following secrets:
  - AWS_SECRET_ACCESS_KEY
  - AWS_ACCESS_KEY_ID
  - AWS_REGION
  - CLUSTER_NAME

- Modify the workflows files  with your config. Change the ECR_REGISTRY variable with your own
- Push your code

- The pipeline will start

### Check deployment

From your local machine you can use the following commands to check status:

```bash

kubectl get svc
kubectl get pods
kubectl get svc  <service_name>
kubectl get deployment  <deployment_name>

```

## Cleanup

To cleanup everything:
```bash
    kubectl delete deployment frontend
    kubectl delete service frontend
    kubectl delete deployment backend
    kubectl delete service backend
```

Destroy the infratructure

```
cd terraform && terraform destroy
```


## License


This project is licensed under the MIT License - see the [LICENSE](LICENSE.txt) file for details.
