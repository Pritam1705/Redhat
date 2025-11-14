<img width="334" height="151" alt="Mosip" src="https://github.com/user-attachments/assets/703db8be-e207-479a-bdeb-4ac4023d246b" />


## Table of Content
- [Runbook for Mosip](#runbook-for-mosip)
- [Architecture of Mosip deployment](#1-architecture-of-mosip-deployment)
- [Difference in MOSIP Documentation vs Ooru Runbook for k8s cluster](#2-difference-in-mosip-documentation-vs-ooru-runbook-for-k8s-cluster)
    - [MOSIP Documentation](#mosip-documentation)
    - [Ooru Runbook](#ooru-runbook)
- [Pre-Requisites](#3-pre-requisites)
    - [Git](#git-version-2251-or-higher)
    - [Environment Variable Configuration](#environment-variable-configuration)
    - [kubectl](#kubectl-version-2124-or-higher)
    - [Istioctl](#istioctl-version-1150)
    - [rke](#rke-version-v1310)
    - [Helm](#helm-installation-any-client-version-above-300)
    - [Ansible](#ansible-version--2124)
    - [Clone Repo](#clone-k8s-infra-repo-with-tag--1202)
    - [Hardware requirements](#hardware-requirements)
    - [DNS requirements](#dns-requirements)
- [On-Premises Deployment](#on-premises-deployment)
     - [Wireguard setup](#1-wireguard-bastion-server-setup)
     - [Observation cluster setup](#2-observation-k8s-cluster-setup-and-configuration)
     - [Observation K8s Cluster Ingress, Storageclass setup](#3-observation-k8s-cluster-ingress-storageclass-setup)
     - [Setting up Nginx Server for Observation K8s Cluster](#4-setting-up-nginx-server-for-observation-k8s-cluster)
     - [Observation K8's Cluster Apps Installation](#5-observation-k8s-cluster-apps-installation)
     - [Cluster Global Configmap](#7-mosip-k8-cluster-global-configmap-ingress-and-storage-class-setup)
     - [Import MOSIP Cluster into Rancher UI](#8-import-mosip-cluster-into-rancher-ui)
- [MOSIP External Dependencies](#mosip-external-dependencies-setup)
    - [PostgreSQL](#1-postgresql-installation)
    - [Keycloak](#2-keycloak)
    - [SoftHSM](#3-setup-softhsm)
    - [MinIO](#4-minio-installation)
    - [S3 Credentials](#5-s3-credentials-setup)
    - [ClamAV](#6-clamav-setup)
    - [ActiveMQ](#7-activemq-setup)
    - [Kafka](#8-kafka-setup)
    - [MSG Gateway](#9-msg-gateway)
    - [Captcha](#10-captcha)
    - [Landing page](#11-landing-page-setup)
- [MOSIP Modules Deployment](#11-mosip-modules-deployment)
    - [Conf secrets](#1-conf-secrets)
    - [Config Server](#2-config-server)
    - [Artifactory](#3-artifactory)
    - [Keymanager](#4-keymanager)
    - [WebSub](#5-websub)
    - [Mock-SMTP](#6-mock-smtp)
    - [Kernel](#7-kernel)
    - [Masterdata-loader](#8-masterdata-loader)
    - [Mock-biosdk](#9-mock-biosdk)
    - [Packetmanager](#10-packetmanager)
    - [Datashare](#11-datashare)
    - [Pre-reg](#12-pre-reg)
    - [Idrepo](#13-idrepo)
    - [Partner Management Services](#14-partner-management-services)
    - [Mock ABIS](#15-mock-abis)
    - [Mock-mv](#16-mock-mv)
    - [Registration Processor](#17-registration-processor)
    - [Admin](#18-admin)
    - [ID Authentication](#19-id-authentication)
    - [Print](#20-print)
    - [Partner Onboarder](#21-partner-onboarder)
    - [MOSIP File Server](#22-mosip-file-server)
    - [Resident services](#23-resident-services)
    - [Registration Client](#24-registration-client)

- [API Testrig Setup](#api-testrig-setup)

# Runbook for Mosip

- **Comprehensive Deployment Flow:**  
  Provides a detailed, step-by-step process — from **infrastructure setup** to **module deployment** — including all necessary commands for seamless execution.

- **OS Transparency:**  
  Clearly specifies the **OS image** used for each node, ensuring consistency and ease of replication across environments.

- **Reliable & Verified Images:**  
  Utilizes **active and verified OS images**, guaranteeing smooth, stable, and error-free deployment of all **MOSIP modules**.


## 1) Architecture of Mosip deployment

<img width="914" height="535" alt="mosip-arch" src="https://github.com/user-attachments/assets/be376b92-ca55-4912-a682-0e40e433be93" />



## 2) Difference in MOSIP Documentation vs Ooru Runbook for k8s cluster

- ### **MOSIP Documentation**
     - The MOSIP External Module (Postgres) image used is deprecated it needs to be updated in the deployment script.
     - It does not mention that the Monitoring deployment step can be skipped.

- ### **Ooru Runbook**
    - Provides a step-by-step process from infrastructure setup to module deployment, including all necessary commands.

    - Uses active and verified images, ensuring smooth deployment of all MOSIP modules without issues.

## 3) Pre-Requisites 
- Install all the required tools on bastion host

- ### **Git (version 2.25.1 or higher)**

```
sudo apt update
sudo apt install git
```
- ### **Environment Variable Configuration**

```
export MOSIP_ROOT=/home/ubuntu
export K8_ROOT=$MOSIP_ROOT/k8s-infra
export INFRA_ROOT=$MOSIP_ROOT/mosip-infra
```

- ### **kubectl (version 2.12.4 or higher)**

```
curl -LO "https://dl.k8s.io/release/v1.34.1/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client
```
- ### **Istioctl (version: 1.15.0)**

```
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.15.0 sh -
cd istio-1.15.0
sudo mv bin/istioctl /usr/local/bin/
istioctl version --remote=false
```
- ### **rke (version v1.3.10)**

```
curl -L "https://github.com/rancher/rke/releases/download/v1.3.10/rke_linux-amd64" -o rke
chmod +x rke
sudo mv rke /usr/local/bin/
rke --version
```

- ### **helm installation (any client version above 3.0.0)**

```
Curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add mosip https://mosip.github.io/mosip-helm
```

- ### **Ansible (version > 2.12.4)**

```
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y
```
- ### **clone k8’s infra repo with tag : 1.2.0.2**
```
git clone https://github.com/mosip/k8s-infra -b v1.2.0.2
```

## Hardware requirements

> *Here, we are referring to Ubuntu OS (22.04) throughout this installation guide.*  
> Source: [MOSIP Pre-Requisites](https://docs.mosip.io/1.2.0/setup/deploymentnew/v3-installation/1.2.0.2/pre-requisites) 

| Sl no. | Purpose | vCPU’s | RAM | Storage (HDD) | Number of VMs | HA | os image
|--------|---------|--------|------|----------------|----------------|-----|----------|
| 1 | Wireguard Bastion Host | 2 | 4 GB | 8 GB | 1 | (Active-Passive) | 22.04 (ubuntu)
| 2 | Observation Cluster nodes | 2 | 8 GB | 32 GB | 2 | 2 | 22.04 (ubuntu)
| 3 | Observation Nginx server (or Load Balancer) | 2 | 4 GB | 16 GB | 1 | Nginx+ | 22.04 (ubuntu)
| 4 | MOSIP Cluster nodes | 12 | 32 GB | 128 GB | 6 | 6 | 22.04 (ubuntu)
| 5 | MOSIP Nginx server (or Load Balancer) | 2 | 4 GB | 16 GB | 1 | Nginx+ | 22.04 (ubuntu)


## DNS requirements

| # | Domain Name | Mapping Details | Purpose |
| :---: | :--- | :--- | :--- |
| 1 | `rancher.xyz.net` | Private IP of Nginx server or load balancer for **Observation cluster** | Rancher dashboard for Kubernetes cluster monitoring and management. |
| 2 | `keycloak.xyz.net` | Private IP of Nginx server for **Observation cluster** | Administrative IAM tool (Keycloak) for Kubernetes administration. |
| 3 | `sandbox.xyx.net` | Private IP of Nginx server for **MOSIP cluster** | Index page for links to different dashboards of MOSIP environment. (Internal reference only, do not expose in production/UAT). |
| 4 | `api-internal.sandbox.xyz.net` | Private IP of Nginx server for **MOSIP cluster** | Internal APIs exposed and accessible privately over the Wireguard channel. |
| 5 | `api.sandbox.xyx.net` | Public IP of Nginx server for **MOSIP cluster** | All publicly usable APIs are exposed using this domain. |
| 6 | `prereg.sandbox.xyz.net` | Public IP of Nginx server for **MOSIP cluster** | MOSIP's pre-registration portal, accessible publicly. |
| 7 | `activemq.sandbox.xyx.net` | Private IP of Nginx server for **MOSIP cluster** | Direct access to the ActiveMQ dashboard, limited to access over Wireguard. |
| 8 | `kibana.sandbox.xyx.net` | Private IP of Nginx server for **MOSIP cluster** | Optional installation. Used to access the Kibana dashboard over Wireguard. |
| 9 | `regclient.sandbox.xyz.net` | Private IP of Nginx server for **MOSIP cluster** | Registration Client download domain, accessible over Wireguard. |
| 10 | `admin.sandbox.xyz.net` | Private IP of Nginx server for **MOSIP cluster** | MOSIP's Admin portal, restricted to access over Wireguard. |
| 11 | `object-store.sandbox.xyx.net` | Private IP of Nginx server for **MOSIP cluster** | Optional. Used to access the object server console (e.g., MinIO Console) over Wireguard. |
| 12 | `kafka.sandbox.xyz.net` | Private IP of Nginx server for **MOSIP cluster** | Access to Kafka UI for administrative needs over Wireguard. |
| 13 | `iam.sandbox.xyz.net` | Private IP of Nginx server for **MOSIP cluster** | Access to the OpenID Connect server (Keycloak) for managing service access over Wireguard. |
| 14 | `postgres.sandbox.xyz.net` | Private IP of Nginx server for **MOSIP cluster** | Points to the PostgreSQL server. Connection is typically via port forwarding over Wireguard. |
| 15 | `pmp.sandbox.xyz.net` | Private IP of Nginx server for **MOSIP cluster** | MOSIP's Partner Management Portal, accessed over Wireguard. |
| 16 | `onboarder.sandbox.xyz.net` | Private IP of Nginx server for **MOSIP cluster** | Accessing reports for MOSIP partner onboarding over Wireguard. |
| 17 | `resident.sandbox.xyz.net` | Public IP of Nginx server for **MOSIP cluster** | Accessing the Resident Portal publicly. |
| 18 | `idp.sandbox.xyz.net` | Public IP of Nginx server for **MOSIP cluster** | Accessing the IDP publicly. |
| 19 | `smtp.sandbox.xyz.net` | Private IP of Nginx server for **MOSIP cluster** | Accessing the mock-SMTP UI over Wireguard. |


## On-Premises Deployment

# 1. Wireguard Bastion Server Setup

The Wireguard bastion server provides a secure, private channel to access the MOSIP cluster nodes. 



### 1.a. Setup Wireguard VM and Bastion Server

1.  **Create VM:** Create a Wireguard server VM according to the specified 'Hardware and Network Requirements'.

2.  **Prepare Ansible Inventory :**
    * Navigate to the Wireguard directory:
        ```bash
        cd $K8_ROOT/wireguard/
        ```
    * Create a copy of `hosts.ini.sample` and update details:
        ```bash
        cp hosts.ini.sample hosts.ini
        ```
    * **Note:** Remove the complete `[Cluster]` section from `hosts.ini`.
    * Update the following details for the Wireguard VM:
        * `ansible_host`: Public IP of the Wireguard Bastion server.
        * `ansible_user`: User for installation (e.g., `ubuntu`).
        * `ansible_ssh_private_key_file`: Path to the SSH private key (e.g., `~/.ssh/wireguard-ssh.pem`).

3.  **Open Required Ports (UFW):**
    *  enable ports which are present in port.yml on the VM using `ufw`:
 
    > **Security Notes:**
    > * Ensure the SSH private key has `400` permissions: `sudo chmod 400 ~/.ssh/privkey.pem`.
    > * The Wireguard server listens on **UDP port 51820**. Ensure this port is open on the VM and any external firewall. 

4.  **Install Docker:**
    * Execute `docker.yml` to install Docker and add the user to the Docker group:
        ```bash
        ansible-playbook -i hosts.ini docker.yaml
        ```

### 1.b. Setup Wireguard Server (on Wireguard VM)

1.  **SSH to Wireguard VM:**
    ```bash
    ssh -i <path to .pem> ubuntu@<Wireguard server public ip>
    ```

2.  **Create Config Directory:**
    ```bash
    mkdir -p wireguard/config
    ```

3.  **Install and Start Wireguard Server (using Docker):**
    ```bash
    sudo docker run -d \
    --name=wireguard \
    --cap-add=NET_ADMIN \
    --cap-add=SYS_MODULE \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=Asia/Calcutta \
    -e PEERS=30 \
    -p 51820:51820/udp \
    -v /home/ubuntu/wireguard/config:/config \
    -v /lib/modules:/lib/modules \
    --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
    --restart unless-stopped \
    ghcr.io/linuxserver/wireguard
    ```
    > **Note:**
    > * Increase `-e PEERS=30` if more than 30 client configurations are needed.
  



# 2. Observation K8s Cluster setup and configuration

## 2.1. Initial Setup and Configuration

### **Install Required Tools**

* Install all the required tools (e.g., `ssh`, `ansible`, `rke`, `kubectl`).

### **VM Hardware and Network Configuration**

* Setup Observation Cluster node VM’s hardware and network configuration as per (requirements).

### **Setup Passwordless SSH**

Setup passwordless SSH into the cluster nodes via pem keys. (Ignore if VM’s are accessible via pem’s).

1.  **Generate keys on your PC:**
    ```bash
    ssh-keygen -t rsa
    ```
2.  **Copy the keys to remote observation node VM’s:**
    ```bash
    ssh-copy-id <remote-user>@<remote-ip>
    ```
3.  **SSH into the node to check password-less SSH:**
    ```bash
    ssh -i ~/.ssh/<your private key> <remote-user>@<remote-ip>
    ```

> **Note:**
> Make sure the permission for `privkey.pem` for ssh is set to `400`.
> ```bash
> chmod 400 ~/.ssh/<your private key>
> ```

### **Prepare and Execute Ansible Playbooks**

Open ports and install Docker on Observation K8 Cluster node VM’s.

1.  **Navigate to the Ansible directory:**
    ```bash
    cd $K8_ROOT/rancher/on-prem
    ```
2.  **Copy and Update `hosts.ini`:**
    Copy `hosts.ini.sample` to `hosts.ini` and update required details.
    ```bash
    cp hosts.ini.sample hosts.ini
    ```


3.  **Update `ports.yaml`:**
    Update `vpc_ip` variable in `ports.yaml` with VPC CIDR ip to allow access only from machines inside same VPC.


4.  **Enable ports on VM level which is present in ports.yaml:**


5.  **Disable swap in cluster nodes. (Ignore if swap is already disabled):**
    ```bash
    ansible-playbook -i hosts.ini swap.yaml
    ```
    > **Caution:** Always verify swap status with `swapon --show` before running the playbook to avoid unnecessary operations.

6.  **Execute `docker.yml` to install docker and add user to docker group:**
    ```bash
    ansible-playbook -i hosts.ini docker.yaml
    ```

## 2.2. Creating RKE Cluster Configuration file

1.  **Generate `cluster.yml` using `rke config`:**
    ```bash
    rke config
    ```
    The command will prompt for nodal details related to the cluster.
    * **SSH Private Key Path:** `<path/to/your/ssh/private/key>`
    * **Number of Hosts:** `<number of cluster nodes>`
    * **SSH Address of host:** `<node-ip>`
    * **SSH User of host:** `<remote-user>`
    * **Is host (<node1-ip>) a Control Plane host (y/n)? [y]:** `y` (For the first node)
    * **Is host (<node1-ip>) a Worker host (y/n)? [n]:** `y`
    * **Is host (<node1-ip>) an etcd host (y/n)? [n]:** `y` (For the first node)

    > **Key Points:**
 
    > * To create an HA cluster, specify more than one host with role **Control Plane** and **etcd host**.
 

2.  **Update `cluster.yml`:**
    As a result of `rke config` command, `cluster.yml` file will be generated inside the same directory. Update the below mentioned fields:
    ```bash
    vi cluster.yml
    ```
    * **Remove the default Ingress install:**
        ```yaml
        ingress:
          provider: none
        ```
    * **Update the name of the kubernetes cluster:**
        ```yaml
        cluster_name: observation-cluster
        ```


## 2.3. Setup up the Cluster

1.  **Bring up the Kubernetes cluster:**
    Once `cluster.yml` is ready, you can bring up the kubernetes cluster using a simple command. 
    ```bash
    rke up
    ```
    Example successful output:
    ```
    INFO[0000] Building Kubernetes cluster
    INFO[0000] [dialer] Setup tunnel for host [10.0.0.1]
    INFO[0000] [network] Deploying port listener containers   
    INFO[0000] [network] Pulling image [alpine:latest] on host [10.0.0.1]
    ...
    INFO[0101] Finished building Kubernetes cluster successfully
    ```
    The last line should read `Finished building Kubernetes cluster successfully` to indicate that your cluster is ready to use.


## 2.4. Access and Verification



1.  **Access the cluster using kubeconfig file:**
    Use any one of the below methods:
    * **Option A: Copy to default config path**
        ```bash
        cp $HOME/.kube/<cluster_name>_config $HOME/.kube/config
        ```
    * **Option B: Export KUBECONFIG variable**
        ```bash
        export KUBECONFIG="$HOME/.kube/<cluster_name>_config"
        ```

2.  **Test cluster access:**
    ```bash
    kubectl get nodes
    ```
    Command will result in details of the nodes of the Observation cluster, showing their status (e.g., `Ready`).
<img width="602" height="63" alt="Screenshot from 2025-11-12 20-24-18" src="https://github.com/user-attachments/assets/722978b2-1049-4b48-9979-b79d74fa6138" />


## 2.5. Save Important Files

Save a copy of the following files in a secure location, as they are needed to maintain, troubleshoot and upgrade your cluster.

* **`cluster.yml`**: The RKE cluster configuration file.
* **`kube_config_cluster.yml`**: The Kubeconfig file for the cluster, this file contains credentials for full access to the cluster.
* **`cluster.rkestate`**: The Kubernetes Cluster State file, this file contains credentials for full access to the cluster.


## 3. Observation K8s Cluster Ingress, Storageclass setup

Once the RKE cluster is ready, an Ingress Controller and Storage Class must be configured for other applications.

### 3.a. Nginx Ingress Controller



1.  **Navigate to the installation directory:**
    ```bash
    cd $K8_ROOT/rancher/on-prem
    ```

2.  **Add the Nginx Ingress Helm repository:**
    ```bash
    helm repo add ingress-nginx [https://kubernetes.github.io/ingress-nginx](https://kubernetes.github.io/ingress-nginx)
    ```

3.  **Update the Helm repositories:**
    ```bash
    helm repo update
    ```

4.  **Install the Nginx Ingress Controller using Helm:**
    ```bash
    helm install \                                                                                                             
      ingress-nginx ingress-nginx/ingress-nginx \
      --namespace ingress-nginx \
      --version 4.0.18 \
      --create-namespace  \
      -f ingress-nginx.values.yaml
    ```

5.  **Cross-check the installation:**
    Verify that all necessary components (pods, deployments, etc.) are running in the new namespace.
    ```bash
    kubectl get all -n ingress-nginx
    ```
  
### 3.b. Storage Classes (NFS)



#### **I. NFS Server Setup (on NFS VM)**

1.  **Prepare Ansible Inventory:**
    * Navigate to the NFS directory on your personal computer:
        ```bash
        cd $K8_ROOT/mosip/nfs
        ```
    * Copy and update `hosts.ini` with the NFS server details:
        ```bash
        cp hosts.ini.sample hosts.ini
        ```
        > **Note:** Update `ansible_host` (NFS server IP), `ansible_user`, and `ansible_ssh_private_key_file` in `hosts.ini`.


2.  **Enable NFS Firewall Ports (Ansible):**
    *  Enable required ports which is present in port.yml on the NFS VM:


3.  **Install NFS Server Software (on NFS VM):**
    * SSH into the NFS VM:
        ```bash
        ssh -i ~/.ssh/nfs-ssh.pem ubuntu@<internal ip of nfs server>
        ```
    * Clone the repository and run the installation script:
        ```bash
        git clone [https://github.com/mosip/k8s-infra](https://github.com/mosip/k8s-infra) -b v1.2.0.1
        cd /home/ubuntu/k8s-infra/mosip/nfs/
        sudo ./install-nfs-server.sh
        ```
    * **Note:** The script will prompt you to enter the `Environment Name` (e.g., `dev`, `qa`).
        ```
        Please Enter Environment Name: <envName>
        NFS Server Path: /srv/nfs/mosip/<envName>
        ```

#### **II. NFS Client Provisioner Setup**

1.  **Run the Client Provisioner Script:**
  
        ```bash
        cd $K8_ROOT/mosip/nfs/
        ./install-nfs-client-provisioner.sh
        ```
    * **Note:** The script will prompt for:
        * **NFS Server:** The IP of your NFS server.
        * **NFS Path:** The path for persisted data (e.g., `/srv/nfs/mosip/<envName>`).

2.  **Post-Installation Check:**
    * **Check Provisioner Deployment Status:**
        ```bash
        kubectl -n nfs get deployment.apps/nfs-client-provisioner 
        ```
    * **Check Storage Class Status:**
        ```bash
        kubectl get storageclass
        ```

## 4. Setting up Nginx Server for Observation K8s Cluster

The Nginx server acts as a reverse proxy for the cluster, handling TLS termination and routing traffic.

### 4.a. SSL Certificate Setup for TLS Termination



1.  **SSH into the Nginx Server VM.**
2.  **Install Pre-requisites (on Nginx VM):**
    ```bash
    sudo apt update -y
    sudo apt-get install software-properties-common -y
    sudo add-apt-repository ppa:deadsnakes/ppa
    sudo apt-get update -y
    sudo apt-get install python3.8 -y
    sudo apt install letsencrypt -y
    sudo apt install certbot python3-certbot-nginx -y
    ```
3.  **Generate Wildcard SSL Certificate (using Certbot/Let's Encrypt):**
    ```bash
    sudo certbot certonly --agree-tos --manual --preferred-challenges=dns -d *.credissure.com
    # Replace org.net with your domain.
    ```
    > **Note:** This uses a DNS challenge, requiring you to create a `TXT` record (`_acme-challenge.<your-domain>`) in your DNS service with the string prompted by the script. Verify the entry is active using `host -t TXT _acme-challenge.credissure.com`.


### 4.b. Install Nginx

1.  **Prepare Ansible Inventory (on Personal Computer):**
    * Navigate to the Nginx directory:
        ```bash
        cd $K8_ROOT/mosip/on-prem/nginx/
        ```
    * Create and edit `hosts.ini`:
        ```bash
        nano hosts.ini
        ```
    * Add the Nginx server details:
        ```ini
        [nginx]
        node-nginx ansible_host=<internal ip> ansible_user=root ansible_ssh_private_key_file=<pvt .pem file>
        ```

2.  **Open Required Ports from port.yml:**


3.  **Install Nginx Software (on Nginx VM):**
    * SSH into the Nginx server node:
        ```bash
        ssh -i ~/.ssh/<pem to ssh> ubuntu@<nginx server ip>
        ```
    * Clone the repository and execute the installation script:
        ```bash
        cd $K8_ROOT/rancher/on-prem/nginx
        sudo ./install.sh
        ```
    * **Provide Inputs when prompted:**
        * **Rancher nginx ip:** Internal IP of the Nginx server VM.
        * **SSL cert path:** Path to the SSL certificate (e.g., from `/etc/letsencrypt`).
        * **SSL key path:** Path to the SSL key.
        * **Cluster node ip's:** IPs of the RKE cluster nodes.

4.  **Post Installation Check:**
    ```bash
    sudo systemctl status nginx
    ```

5.  **DNS Mapping:** Create DNS records for domains like `rancher.credissure.com` and `keycloak.credissure.com` pointing to the Nginx server's public IP. 

---

## 5. Observation K8's Cluster Apps Installation

### 5.a. Rancher UI

1.  **Install Rancher using Helm:**
    * Navigate to the Rancher directory:
        ```bash
        cd $K8_ROOT/rancher/rancher-ui
        ```
    * Add and update the Helm repository:
        ```bash
        helm repo add rancher-latest [https://releases.rancher.com/server-charts/latest](https://releases.rancher.com/server-charts/latest)
        helm repo update
        ```
    * **Install Rancher:** Update the hostname in `rancher-values.yaml` eg. rancher.credissure.com and execute:
        ```bash
        helm install rancher rancher-latest/rancher \
        --version 2.6.9 \
        --namespace cattle-system \
        --create-namespace \
        -f rancher-values.yaml
        ```

2.  **Initial Login:**
    * Access the Rancher page via the browser (ensure Wireguard/VPN is connected).
    * Get the bootstrap password:
        ```bash
        kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{ .data.bootstrapPassword|base64decode}}{{ "\n" }}'
        ```
   

## 6. MOSIP K8s Cluster Setup



### 6.1. Pre-requisites & Initial Checks

1.  **Install Tools:** Ensure the following tools are installed on your PC: `kubectl`, `helm`, `ansible`, `rke` (version 1.3.10).
2.  **Add Helm Repositories:**
    ```bash
    helm repo add bitnami [https://charts.bitnami.com/bitnami](https://charts.bitnami.com/bitnami)
    helm repo add mosip [https://mosip.github.io/mosip-helm](https://mosip.github.io/mosip-helm)
    ```
3.  **VM Setup:** Configure MOSIP K8 Cluster node VMs as per requirements.


4.  **Setup Passwordless SSH:** Ensure passwordless SSH is configured using `ssh-keygen` and `ssh-copy-id`.

### 6.2. Prepare and Execute Ansible Playbooks

1.  **Navigate to MOSIP Ansible directory:** `cd $K8_ROOT/mosip/on-prem`.
2.  **Update `hosts.ini`** (Copy from sample if not already done).
3.  **Update `ports.yaml`:** Set `vpc_ip` with the VPC CIDR range.
4.  **Execute Playbooks:**
    * **Enable Ports which is present in port.yml:**
    * **Disable Swap:**
        ```bash
        ansible-playbook -i hosts.ini swap.yaml
        ```
    * **Install Docker:**
        ```bash
        ansible-playbook -i hosts.ini docker.yaml
        ```

### 6.3. Creating and Launching the RKE Cluster

1.  **Generate `cluster.yml`:**
    ```bash
    rke config
    ```

2.  **Update `cluster.yml`:**
    * Remove default Ingress:
        ```yaml
        ingress:
          provider: none
        ```
    * Update Cluster Name:
        ```yaml
        cluster_name: mosip-cluster
        ```

3.  **Launch Cluster:**
    ```bash
    rke up
    ```
    * Wait for the message: `Finished building Kubernetes cluster successfully`.

4.  **Kubeconfig and Verification:**
    * Copy and secure the kubeconfig file:
        ```bash
        cp kube_config_cluster.yml $HOME/.kube/<cluster_name>_config
        chmod 400 $HOME/.kube/<cluster_name>_config
        export KUBECONFIG="$HOME/.kube/<cluster_name>_config"
        ```
    * Test cluster access:
        ```bash
        kubectl get nodes
        ```
        <img width="931" height="171" alt="Screenshot from 2025-11-12 21-05-55" src="https://github.com/user-attachments/assets/7a59f818-51e7-4121-8579-e97767617ae3" />

5.  **Save Files:** Securely back up `cluster.yml`, `kube_config_cluster.yml`, and `cluster.rkestate`.

---

## 7. MOSIP K8 Cluster Global Configmap, Ingress and Storage Class setup

### 7.a. Global Configmap

This contains necessary common details for applications across the MOSIP cluster namespaces.

1.  **Prepare Configmap:**
    * Navigate to the MOSIP root directory: `cd $K8_ROOT/mosip`.
    * Copy and update domain names in the configuration file:
        ```bash
        cp global_configmap.yaml.sample global_configmap.yaml
        ```
2.  **Apply Configmap:**
    ```bash
    kubectl apply -f global_configmap.yaml
    ```

### 7.b. Istio Ingress Setup



1.  **Install Istio:**
    * Navigate to the Istio directory: `cd $K8_ROOT/mosip/on-prem/istio`.
    * Run the installation script:
        ```bash
        ./install.sh
        ```
    > **Note:** This installs all Istio components and Ingress Gateways.

2.  **Check Ingress Gateway Services:**
    ```bash
    kubectl get svc -n istio-system
    ```
    * **Verify:** The response should include `istio-ingressgateway` (external), `istio-ingressgateway-internal` (internal), and `istiod`.


### 7.c. Storage Classes (NFS)



#### **I. NFS Server Preparation (on Personal Computer)**

1.  **Prepare Ansible Inventory:**
    * Navigate to the NFS directory:
        ```bash
        cd $K8_ROOT/mosip/nfs
        ```
    * Copy and update `hosts.ini` with the **NFS server VM details** (IP, user, SSH key path).
        ```bash
        cp hosts.ini.sample hosts.ini
        ```

2.  **Verify Kubeconfig:**
    * Ensure `kubectl` is pointing to the **MOSIP Cluster**:
        ```bash
        kubectl config view
        ```

3.  **Enable NFS Firewall Ports (Ansible):**
    * Enable required ports which is present in port.yml on the NFS VM :


#### **II. Install NFS Server (on NFS VM)**

1.  **SSH and Clone Repo:**
    * SSH into the NFS VM:
        ```bash
        ssh -i ~/.ssh/nfs-ssh.pem ubuntu@<internal ip of nfs server>
        ```
    * Clone the repository (if not already present):
        ```bash
        git clone [https://github.com/mosip/k8s-infra](https://github.com/mosip/k8s-infra) -b v1.2.0.1
        ```
    * Move to the NFS directory:
        ```bash
        cd /home/ubuntu/k8s-infra/mosip/nfs/
        ```

2.  **Execute NFS Server Installation:**
    * Run the script to install the NFS server software:
        ```bash
        sudo ./install-nfs-server.sh
        ```
    * **Note:** When prompted, enter the **Environment Name** (e.g., `sandbox`).
        ```
        Please Enter Environment Name: <envName>
        NFS Server Path: /srv/nfs/mosip/<envName>
        ```

#### **III. Install NFS Client Provisioner**

1.  **Run Client Provisioner Script:**
    * Switch back to your bastion host machine and run the installation script:
        ```bash
        cd $K8_ROOT/mosip/nfs/
        ./install-nfs-client-provisioner.sh
        ```
    * **Note:** The script will prompt for the **NFS Server IP** and the **NFS Path** (e.g., `/srv/nfs/mosip/<envName>`).

2.  **Post-Installation Check:**
    * **Check Provisioner Deployment Status:**
        ```bash
        kubectl -n nfs get deployment.apps/nfs-client-provisioner 
        ```
    * **Check Storage Class Status:**
        ```bash
        kubectl get storageclass
        ```
        Verify that `nfs-client` is listed as an available Storage Class.

## 8. Import MOSIP Cluster into Rancher UI



1.  **Login to Rancher:** Access the Rancher console using the admin credentials.
2.  **Start Import:** Click **Import Existing** for cluster addition.
3.  **Cluster Details:** Select **Generic** as the cluster type. Fill the **Cluster Name** field with a unique name (e.g., `mosip-sandbox`). Select **Create**.
4.  **Execute Import Command:** Rancher will provide a `kubectl apply` command.
    * **Ensure Kubeconfig is set to the MOSIP Cluster.**
    * Copy and execute the command from your PC:
        ```bash
        kubectl apply -f https://<rancher-host>/v3/import/<cluster-id>.yaml
        ```
5.  **Verification:** Wait for the cluster to be verified and show as **Active** in the Rancher UI.

---

## 9. MOSIP K8 Cluster Nginx Server Setup

### 9.a. SSL Certificates Creation

- You already have the certificate; you can use this one as well.

### 9.b. Nginx Server Setup for MOSIP K8s Cluster

1.  **Prepare Ansible Inventory :**
    * Navigate to the Nginx directory: `cd $K8_ROOT/mosip/on-prem/nginx/`.
    * Create/Update `hosts.ini` with the MOSIP Nginx server details:
        ```ini
        [nginx]
        node-nginx ansible_host=<internal ip> ansible_user=root ansible_ssh_private_key_file=<pvt .pem file>
        ```

2.  **Enable the required ports that are specified in **port.yml**:**


3.  **Install Nginx Software (on Nginx VM):**
    * Login to the Nginx server node.
    * Clone the repository and execute the installation script:
        ```bash
        cd $K8_ROOT/mosip/on-prem/nginx
        sudo ./install.sh
        ```
    * **Provide Inputs:** The script will prompt for:
        * MOSIP Nginx server internal IP
        * MOSIP Nginx server public IP
        * Publicly accessible domains (comma separated)
        * SSL certificate path (`/etc/letsencrypt/live/...`)
        * SSL key path (`/etc/letsencrypt/live/...`)
        * Cluster node IPs (comma separated)

4.  **Post Installation Check:**
    ```bash
    sudo systemctl status nginx
    ```
5.  **DNS Mapping:** Finalize DNS records pointing to the Nginx server (Public/Private IP) as defined in the DNS Requirements section.

### 9.c. Check Overall Nginx and Istio Wiring

Use the `httpbin` utility to verify traffic routing and header transmission through the Nginx/Istio setup.

1.  **Install Httpbin:**
    * Navigate to the utility directory: `cd $K8_ROOT/utils/httpbin`.
    * Run the installation script:
        ```bash
        ./install.sh
        ```

2.  **Test Connectivity:** Check if requests reach `httpbin` via internal and public domains (replace domains with your actual values):
    ```bash
    curl [https://api.sandbox.xyz.net/httpbin/get?show_env=true](https://api.sandbox.xyz.net/httpbin/get?show_env=true)
    curl [https://api-internal.sandbox.xyz.net/httpbin/get?show_env=true](https://api-internal.sandbox.xyz.net/httpbin/get?show_env=true)
    ```
    **Verification:** The output should show the HTTP headers received inside the cluster.



# MOSIP External Dependencies setup

#### 1. PostgreSQL Installation

PostgreSQL is required as the primary relational database for the MOSIP services.

### 1.1. Installation

1.  **Navigate to the installation directory:**
    ```bash
    cd $INFRA_ROOT/deployment/v3/external/postgres
    ```

2.  **Execute the installation script:**
    ```bash
    ./install.sh
    ```

- Change image of postgres i.e,
( **helm -n $NS install postgres-postgresql bitnami/postgresql --version 12.11.1 -f values.yaml --set image.repository=mosipint/postgresql --set  image.tag="16.0.0-debian-11-r13-amd64-linux" --wait**  ) in **install.sh**
<img width="1300" height="675" alt="postgres" src="https://github.com/user-attachments/assets/198e0713-e6c0-45de-9f7a-a70033511630" />


3.  **Execute the installation script:**
    ```bash
    cd $INFRA_ROOT/deployment/v3/external/postgres
      ./init_db.sh
    ```
- Opt for yes and enter Y.

#### 2. Keycloak

1.  **Navigate to the installation directory:**
    ```bash
    cd $INFRA_ROOT/deployment/v3/external/iam
    ```
2.  **Execute the installation script:**
    ```bash
    ./install.sh
    ```

3. **Initialize Keycloak:**
   ```bash
    cd $INFRA_ROOT/deployment/v3/external/iam
    ./keycloak_init.sh
    ```

- When we run this it will ask some prompt we have to do according to this

```
Provide 'SMTP host' for keycloak : smtp.gmail.com
Provide 'SMTP port' for keycloak : 465
Provide 'From email address' for keycloak SMTP : mosipqa@gmail.com
Provide Would you like to enable 'starttls' configuration for SMTP ? (false/true) : [ Default: false ] : 
Provide Would you like to enable "AUTHENTICATION" configuration for SMTP ? (true/false) : [ Default: true ] : 
Provide Would you like to enable "SSL" fro SMTP ? (true/false) : [ Default: true ] : 
Provide Provide SMTP login Username : mosipqa@gmail.com
Provide Provide SMTP login Password : ogchzjcpjduvzuvz
```
#### 3. Setup SoftHSM

1. **Navigate to the installation directory &Execute the installation script:**
    ```bash
    cd $INFRA_ROOT/deployment/v3/external/hsm/softhsm
    ./install.sh
    ```

- Setup Object store
   - Opt 1 for MinIO

   - Opt 2 for S3 (incase you are not going with MinIO installation and want s3 to be installed)

        Enter the prompted details.

#### 4. MinIO installation
1. **Navigate to the installation directory &Execute the installation script:**
 ```bash
    cd $INFRA_ROOT/deployment/v3/external/object-store/minio
./install.sh
```

#### 5. S3 Credentials setup

1. **Navigate to the installation directory &Execute the installation script:**
```
cd $INFRA_ROOT/deployment/v3/external/object-store/
./cred.sh
```
- When we run this it will ask some prompt we have to do according to this

```
Please enter the S3 region" REGION : (Leave blank or enter your specific region, if applicable)
S3 Host: eg. http://minio.minio:9000
```
#### 6. ClamAV setup

1. **Navigate to the installation directory &Execute the installation script:**

```
cd $INFRA_ROOT/deployment/v3/external/antivirus/clamav
./install.sh
```

#### 7. ActiveMQ setup
1. **Navigate to the installation directory &Execute the installation script:**
```
cd $INFRA_ROOT/deployment/v3/external/activemq
./install.sh
```
#### 8. Kafka setup
1. **Navigate to the installation directory &Execute the installation script:**
```
cd $INFRA_ROOT/deployment/v3/external/kafka
./install.sh
```

#### 9. MSG Gateway
1. **Navigate to the installation directory &Execute the installation script:**
```
cd $INFRA_ROOT/deployment/v3/external/msg-gateway
./install.sh
```

- **MOSIP provides mock smtp server which will be installed as part of default installation, opt for Y.**

#### 10. Captcha
1. **Navigate to the installation directory &Execute the installation script:**
```
cd $INFRA_ROOT/deployment/v3/external/captcha
./install.sh
```

#### 11. Landing page setup


1. **Navigate to the installation directory &Execute the installation script:**
```
cd $INFRA_ROOT/deployment/v3/external/landing-page
./install.sh
```

# MOSIP Modules Deployment

   #### 1. Conf secrets

**Navigate to the installation directory &Execute the installation script:**
```
cd $INFRA_ROOT/deployment/v3/mosip/conf-secrets
./install.sh
```

#### 2. Config Server
**Navigate to the installation directory &Execute the installation script:**
```
cd $INFRA_ROOT/deployment/v3/mosip/config-server
./install.sh
```

#### 3. Artifactory
**Navigate to the installation directory &Execute the installation script:**
```
cd $INFRA_ROOT/deployment/v3/mosip/artifactory
./install.sh
```

#### 4. Keymanager
**Navigate to the installation directory &Execute the installation script:**
- Add ( --set metrics.enabled=false ) in keymanager mosip/keymanager helm chart because we did not install monitoring components 
<img width="1284" height="104" alt="Screenshot from 2025-10-24 13-23-32" src="https://github.com/user-attachments/assets/6a3d7ba5-9831-4f78-af30-a34a37364c6b" />

```
cd $INFRA_ROOT/deployment/v3/mosip/keymanager
./install.sh
```
#### 5. WebSub
**Navigate to the installation directory &Execute the installation script:**
```
cd $INFRA_ROOT/deployment/v3/mosip/websub
./install.sh
```

#### 6. Mock-SMTP
**Navigate to the installation directory &Execute the installation script:**
```
cd $INFRA_ROOT/deployment/v3/mosip/mock-smtp
./install.sh
```
#### 7. Kernel
**Navigate to the installation directory &Execute the installation script:**
- Add ( --set metrics.enabled=false ) in keymanager mosip/keymanager helm chart because we did not install monitoring components 
<img width="1181" height="505" alt="kernel" src="https://github.com/user-attachments/assets/177be121-5ca8-474e-b0e3-6f7d4ee10e8a" />

```
cd $INFRA_ROOT/deployment/v3/mosip/kernel
./install.sh
```

#### 8. Masterdata-loader 
**Navigate to the installation directory &Execute the installation script:**
```
 cd $INFRA_ROOT/deployment/v3/mosip/masterdata-loader
./install.sh
```

#### 9. Mock-biosdk
**Navigate to the installation directory &Execute the installation script:**
```
 cd $INFRA_ROOT/deployment/v3/mosip/biosdk
./install.sh
```

#### 10. Packetmanager
**Navigate to the installation directory &Execute the installation script:**
- Add ( --set metrics.enabled=false ) in install.sh 
<img width="1010" height="192" alt="packet-manger" src="https://github.com/user-attachments/assets/d654ec66-fd29-4ef3-818d-10d56477662f" />


```
cd $INFRA_ROOT/deployment/v3/mosip/packetmanager
./install.sh
```

#### 11. Datashare
**Navigate to the installation directory &Execute the installation script:**
```
 cd $INFRA_ROOT/deployment/v3/mosip/datashare
./install.sh
```
#### 12. Pre-reg
**Navigate to the installation directory &Execute the installation script:**
- Add ( --set metrics.enabled=false ) in install.sh 
<img width="1265" height="427" alt="prereg" src="https://github.com/user-attachments/assets/e1d929a1-eed6-4fcc-8405-0b30259751ae" />


```
cd $INFRA_ROOT/deployment/v3/mosip/prereg
./install.sh
```

#### 13. Idrepo
**Navigate to the installation directory &Execute the installation script:**
- Add ( --set metrics.enabled=false ) in install.sh 

<img width="1265" height="427" alt="idrepo" src="https://github.com/user-attachments/assets/473ef9c2-c5d9-4491-9f1d-9c7d6ab7e54e" />

```
cd $INFRA_ROOT/deployment/v3/mosip/idrepo
./install.sh
```

#### 14. Partner Management Services
**Navigate to the installation directory &Execute the installation script:**
```
 cd $INFRA_ROOT/deployment/v3/mosip/pms
./install.sh
```

#### 15. Mock ABIS
**Navigate to the installation directory &Execute the installation script:**
- Add ( --set metrics.enabled=false ) in install.sh 

<img width="1265" height="427" alt="mockabis" src="https://github.com/user-attachments/assets/184da136-3bb4-412a-a828-dfb59f7e5073" />

```
cd $INFRA_ROOT/deployment/v3/mosip/mock-abis
./install.sh
```

#### 16. Mock MV
**Navigate to the installation directory &Execute the installation script:**
```
 cd $INFRA_ROOT/deployment/v3/mosip/mock-mv
./install.sh
```

#### 17. Registration Processor
**Navigate to the installation directory &Execute the installation script:**
- Add ( --set metrics.enabled=false ) in install.sh 
<img width="605" height="305" alt="image" src="https://github.com/user-attachments/assets/5503df37-ed3c-40e7-ad92-983b0d8f5368" />

```
cd $INFRA_ROOT/deployment/v3/mosip/regproc
./install.sh
```

- For landing zone : 
kubectl edit deploy regproc-trans -n regproc change image name and tag  for landingzone
 
- Use this image tag : 
image: **docker.io/mosipid/registration-processor-registration-transaction-service:1.2.0.1**
<img width="1273" height="640" alt="Screenshot from 2025-10-24 13-45-15" src="https://github.com/user-attachments/assets/44641019-238c-4684-8a88-f4fc5f14a9fa" />



#### 18. Admin
**Navigate to the installation directory &Execute the installation script:**

```
cd $INFRA_ROOT/deployment/v3/mosip/admin
./install.sh
```
#### 19. ID Authentication
**Navigate to the installation directory &Execute the installation script:**
- Add ( --set metrics.enabled=false ) in install.sh
```
 cd $INFRA_ROOT/deployment/v3/mosip/ida
./install.sh
```

#### 20. Print
**Navigate to the installation directory &Execute the installation script:**
- Add ( --set metrics.enabled=false ) in install.sh
```
cd $INFRA_ROOT/deployment/v3/mosip/print
./install.sh
```


#### 21. Partner Onboarder
**Navigate to the installation directory &Execute the installation script:**

```
cd $INFRA_ROOT/deployment/v3/mosip/partner-onboarder
./install.sh
```


#### 22. MOSIP File Server
**Navigate to the installation directory &Execute the installation script:**

```
cd $INFRA_ROOT/deployment/v3/mosip/mosip-file-server
./install.sh
```


#### 23. Resident services
**Navigate to the installation directory &Execute the installation script:**

```
cd $INFRA_ROOT/deployment/v3/mosip/resident
./install.sh
```


#### 24. Registration Client
**Navigate to the installation directory , install jq &Execute the installation script:**

```
cd $INFRA_ROOT/deployment/v3/mosip/regclient
sudo apt-get update
sudo apt-get install jq
./install.sh

```

- For this please install  Please install 1.1.1q version of openSSL

- **Commands** :
```
sudo apt update
sudo apt install build-essential checkinstall zlib1g-dev -y
wget https://www.openssl.org/source/openssl-1.1.1q.tar.gz
tar -xzvf openssl-1.1.1q.tar.gz
cd openssl-1.1.1q
./config --prefix=/usr/local/openssl-1.1.1q --openssldir=/usr/local/openssl-1.1.1q shared zlib
make -j$(nproc)
sudo make install
export PATH=/usr/local/openssl-1.1.1q/bin:$PATH
openssl version
# Should show: OpenSSL 1.1.1q
```

# API Testrig Setup

### Clone and Prepare the Repository

1.  **Navigate to the Infra Root Directory:**
    ```bash
    cd $INFRA_ROOT
    ```

2.  **Clone the Functional Tests Repository:**
    ```bash
    git clone -b v1.3.3 [https://github.com/mosip/mosip-functional-tests.git](https://github.com/mosip/mosip-functional-tests.git)
    ```

3.  **Navigate to the Testrig Deployment Directory:**
    ```bash
    cd $INFRA_ROOT/mosip-functional-tests/deploy/apitestrig
    ```

4.  **Make Script Executable:**
    ```bash
    chmod +x copy_cm_func.sh
    ```

###  Run the Installer Script

Execute the installation script and provide the required inputs when prompted.

```bash
./install.sh
```

### API Testrig Installer Script Inputs

The `./install.sh` script for the API Testrig will prompt for the following information. Please provide the required details as prompted:

| Input Prompt | Example / Default Value | Description |
| :--- | :--- | :--- |
| **Enter the time (hr) to run the cronjob every day (0–23):** | `6` | The hour (0-23) at which you want the daily test run cronjob to execute (e.g., 6 for 6 AM). |
| **Do you have a public domain and valid SSL certificate? (Y/n):** | `Y` or `n` | **Y** if using a public domain with a valid SSL certificate. **n** is recommended only for development environments. |
| **Retention days to remove old reports (Default: 3):** | Press Enter or specify `5` | The number of days to retain old API Testrig reports before they are removed. |
| **Provide Slack Webhook URL to notify server issues...:** | `https://hooks.slack.com/services/...` | The Slack Webhook URL for the channel where you want to receive server issue notifications. |
| **Is the eSignet service deployed? (yes/no):** | `no` | Enter `yes` or `no`. Entering `no` will skip eSignet-related test cases. |
| **Is values.yaml for the apitestrig chart set correctly...? (Y/n):** | `Y` | Enter `Y` if you have already completed the prerequisite configuration of the chart's `values.yaml` file. |
| **Do you have S3 details for storing API-Testrig reports? (Y/n):** | `Y` | Enter `Y` to proceed with configuring an S3-compatible storage service (e.g., MinIO) for reports. |
| **S3 Host:** | `http://minio.minio:9000` | The endpoint of your S3-compatible storage service. |
| **S3 Region:** | (Leave blank or specify) | Your specific S3 region, if applicable. |
| **S3 Access Key:** | `admin` | The S3 access key ID required for authentication. |
