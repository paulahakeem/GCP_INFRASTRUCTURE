# Google Cloud Project
## Project Info.

This project contains:
*  Infrastructure as code using [Terraform](https://www.terraform.io/) that builds an environment on the google cloud platform
* Demo app with Dockerfile
* [Kubernetes](https://kubernetes.io) YAML files for deploying the demo app

## Tools Used

<p align="center">
<a href="https://www.terraform.io/" target="_blank" rel="noreferrer"> <img src="https://raw.githubusercontent.com/AbdEl-RahmanKhaled/AbdEl-RahmanKhaled/main/icons/terraform/terraform-original-wordmark.svg" alt="terraform" width="40" height="40"/> </a> <a href="https://cloud.google.com" target="_blank" rel="noreferrer"> <img src="https://raw.githubusercontent.com/AbdEl-RahmanKhaled/AbdEl-RahmanKhaled/main/icons/googlecloud/googlecloud-original.svg" alt="gcp" width="40" height="40"/> </a> <a href="https://kubernetes.io" target="_blank" rel="noreferrer"> <img src="https://raw.githubusercontent.com/AbdEl-RahmanKhaled/AbdEl-RahmanKhaled/main/icons/kubernetes/kubernetes-icon.svg" alt="kubernetes" width="40" height="40"/> </a> <a href="https://www.python.org" target="_blank" rel="noreferrer"> <img src="https://raw.githubusercontent.com/AbdEl-RahmanKhaled/AbdEl-RahmanKhaled/main/icons/python/python-original.svg" alt="python" width="40" height="40"/> </a>
</p>

## Get Started

### Get The Code 
* Using [Git](https://git-scm.com/), clone the project.

    ```
    git clone git@github.com:paulahakeem/GCP_INFRASTRUCTURE.git
    ```
### Setup Infra
* First setup your GCP account, create new project and change the value of "project_name" variable in terraform/provider.tf with your PROJECT-ID.

* Second build the infrastructure by run

    ```bash
    cd terraform/
    ```

    ``` 
    terraform init
    terraform apply 
    ```
    that will build:
    
    * VPC named "main-vpc"
    * 2 Subnets "management-subnet", "restricted-subnet"
    * 2 Service Accounts
        * "gke-sa" used by Kubernetes cluster
        * "vm_sa" used by Management VM 

    * NAT in "management-subnet"
    * Private Virtual Machine in "management-subnet" subnet to manage the cluster.
    * Private Kubernetes cluster in "restricted-subnet" with 2 worker nodes.

        ```bash
        # NOTE
        Only VMs in "management-subnet" subnet can access the Kubernetes cluster.
        ```
    you can change some variables values in "terraform .tf files"
    
### Build & Push Docker Image to GCR
* Build the Docker Image by run

    ```bash
    docker build -t eu.gcr.io/<PROJECT-ID>/my-app:1.0 src/
    ```
* Setup credentials for docker to Push to GCR 

    ```
    gcloud auth activate-service-account [account-name] --key-file=KEY-FILE
    gcloud auth configure-docker
    ```
* Push the Created Image to GCR

    ```
    docker push eu.gcr.io/<PROJECT-ID>/my-app:1.0
    ```

### Deploy
* After the infrastructure got built, now you can login to the "management-vm" VM using SSH then:
    
    * Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/) tool
    * setup cluster credentials
        ```
        gcloud container clusters get-credentials app-cluster --zone europe-west1-b --project <PROJECT-ID>
        ```
    * Change image in "kubernetes/deployments/app-deployment.yaml" with your image

    * Upload the "k8s" dir to the VM and run
    
        ```
        kubectl apply -f k8s/
        ```

        that will deploy:
        
        * Config Map for environment variables used by demo app
        * Redis Pod and Exopse the pod with ClusterIP service
        * Demo App Deployment and Exopse it with NodePort service
        * Ingress to create HTTP loadbalancer

---
Now, you can access the Demo App by hitting the Ingress IP 