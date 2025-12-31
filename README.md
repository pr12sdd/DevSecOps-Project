<div align="center">
  <img src="./public/assets/DevSecOps.png" alt="Logo" width="100%" height="100%">

  <br>
  <a href="http://netflix-clone-with-tmdb-using-react-mui.vercel.app/">
    <img src="./public/assets/netflix-logo.png" alt="Logo" width="100" height="32">
  </a>
</div>

<br />

<div align="center">
  <img src="./public/assets/home-page.png" alt="Logo" width="100%" height="100%">
  <p align="center">Home Page</p>
</div>

# Deploy Netflix Clone on Cloud using Jenkins - DevSecOps Project!

### **Phase 1: Initial Setup and Deployment**

**Step 1: Provision EC2 (Ubuntu 22.04) using Terraform:**

- Create a directory with the following structure.
```
  terraform/
├── providers.tf      # AWS provider and region
├── main.tf           # EC2 instance, key pair, security group , vpc
├── outputs.tf        # Public IP output
└── variables.tf      # Customizable variables
```
```
  terraform-backend/
├── providers.tf      # AWS provider and region
├── s3.tf             # s3 bucket
├── dynamodbtable.tf  # dynamodb table
├── outputs.tf        # Public IP output
└── variables.tf      # Customizable variables
```
### How to proceed
1. Create the folder: `mkdir terraform && cd terraform`
2. Generate Public and Private Keys:
   ```bash
   ssh-keygen
   ```
4. Create the above files with the required Terraform configuration.
5. Run:
   ```bash
   terraform init
   terraform apply --auto-approve
   ```
6. Create the folder: `mkdir terraform-backend && cd terraform-backend
7. Create the above files with the required Terraform configuration.
8. Run:
   ```bash
   terraform init
   terraform apply --auto-approve
   ```
- Connect to the instance using SSH.

**Step 2: Clone the Code:**

- Update all the packages and then clone the code.
- Clone your application's code repository onto the EC2 instance:
    
    ```bash
    git clone https://github.com/pr12sdd/DevSecOps-Project.git
    ```
**Step 3: Install Docker and Run the App Using a Container:**

- Set up Docker on the EC2 instance:
    
    ```bash
    
    sudo apt-get update
    sudo apt-get install docker.io -y
    sudo usermod -aG docker $USER  # Replace with your system's username, e.g., 'ubuntu'
    newgrp docker
    sudo chmod 777 /var/run/docker.sock
    ```
    
- Build and run your application using Docker containers:
    
    ```bash
    docker build -t netflix .
    docker run -d --name netflix -p 8081:80 netflix:latest
    ```
- For deleting:
   ```bash
    docker stop <containerid>
    docker rmi -f netflix
   ```

It will show an error cause you need API key

**Step 4: Get the API Key:**

- Open a web browser and navigate to TMDB (The Movie Database) website.
- Click on "Login" and create an account.
- Once logged in, go to your profile and select "Settings."
- Click on "API" from the left-side panel.
- Create a new API key by clicking "Create" and accepting the terms and conditions.
- Provide the required basic details and click "Submit."
- You will receive your TMDB API key.

Now recreate the Docker image with your api key:
```
docker build --build-arg TMDB_V3_API_KEY=<your-api-key> -t netflix .
```

### **Phase 2: Security**

**Step 1: Install SonarQube and Trivy:**
    - Install SonarQube and Trivy on the EC2 instance to scan for vulnerabilities.
        
        sonarqube
        ```
        docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
        ```
        
        
        To access: 
        
        publicIP:9000 (by default username & password is admin)
        
        To install Trivy:
        ```
        sudo apt-get install wget apt-transport-https gnupg lsb-release
        wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
        echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
        sudo apt-get update
        sudo apt-get install trivy        
        ```
        
        to scan image using trivy
        ```
        trivy image <imageid>
        ```
        
        
**Step 2: Integrate SonarQube and Configure:**
    - Integrate SonarQube with your CI/CD pipeline.
    - Configure SonarQube to analyze code for quality and security issues.

### **Phase 3: CI/CD Setup**

**Step 1: Install Jenkins for Automation:**
    - Install Jenkins on the EC2 instance to automate deployment:
    Install Java
    
    ```bash
    sudo apt update
    sudo apt install fontconfig openjdk-17-jre
    java -version
    openjdk version "17.0.8" 2023-07-18
    OpenJDK Runtime Environment (build 17.0.8+7-Debian-1deb12u1)
    OpenJDK 64-Bit Server VM (build 17.0.8+7-Debian-1deb12u1, mixed mode, sharing)
    
    #jenkins
    sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt-get update
    sudo apt-get install jenkins
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
    ```
    
    - Access Jenkins in a web browser using the public IP of your EC2 instance.
        
        publicIp:8080
        
**Step 2: Install Necessary Plugins in Jenkins:**

Goto Manage Jenkins →Plugins → Available Plugins →

Install below plugins

1 Eclipse Temurin Installer (Install without restart)

2 SonarQube Scanner (Install without restart)

3 NodeJs Plugin (Install Without restart)

4 Email Extension Plugin

### **Configure Java and Nodejs in Global Tool Configuration**

Goto Manage Jenkins → Tools → Install JDK(17) and NodeJs(16)→ Click on Apply and Save


### SonarQube

- Create the token

- Goto Jenkins Dashboard → Manage Jenkins → Credentials → Add Secret Text. It should look like this

- After adding sonar token

- Click on Apply and Save

**The Configure System option** is used in Jenkins to configure different server

**Global Tool Configuration** is used to configure different tools that we install using Plugins

We will install a sonar scanner in the tools.

Create a Jenkins webhook

1. **Configure CI/CD Pipeline in Jenkins:**
- Create a CI/CD pipeline in Jenkins to automate your application deployment.

```groovy
pipeline {
    agent any
    tools {
        jdk 'jdk17'
        nodejs 'node16'
    }
    environment{
        SCANNER_PATH = tool 'SonarQube'
    }
    stages{
        stage('clean workspace'){
            steps{
                cleanWs()
            }
        }
        stage('code checkout'){
            steps{
                git branch:'master',url:'https://github.com/pr12sdd/DevSecOps-Project.git'
            }
        }
        stage('sonarqube analysis'){
            steps{
                withSonarQubeEnv('sonarqube') {
                sh "$SCANNER_PATH/bin/sonar-scanner -Dsonar.projectName=Netflix-clone -Dsonar.projectKey=Netflix-clone"
            }
        }
    }
        stage('Quality Gate'){
            steps{
                script{
                    waitForQualityGate abortPipeline:false , credentialsId: 'squ_b68070934401ab55478baa0482c7ee8f5c6e7823'
                }
            }
        }
        stage('Install Dependencies'){
            steps{
            sh 'npm install'
            }
        }
}
```

Certainly, here are the instructions without step numbers:

**Install Dependency-Check and Docker Tools in Jenkins**

**Install Dependency-Check Plugin:**

- Go to "Dashboard" in your Jenkins web interface.
- Navigate to "Manage Jenkins" → "Manage Plugins."
- Click on the "Available" tab and search for "OWASP Dependency-Check."
- Check the checkbox for "OWASP Dependency-Check" and click on the "Install without restart" button.

**Configure Dependency-Check Tool:**

- After installing the Dependency-Check plugin, you need to configure the tool.
- Go to "Dashboard" → "Manage Jenkins" → "Global Tool Configuration."
- Find the section for "OWASP Dependency-Check."
- Add the tool's name, e.g., "DP-Check."
- Save your settings.

**Install Docker Tools and Docker Plugins:**

- Go to "Dashboard" in your Jenkins web interface.
- Navigate to "Manage Jenkins" → "Manage Plugins."
- Click on the "Available" tab and search for "Docker."
- Check the following Docker-related plugins:
  - Docker
  - Docker Commons
  - Docker Pipeline
  - Docker API
  - docker-build-step
- Click on the "Install without restart" button to install these plugins.

**Add DockerHub Credentials:**

- To securely handle DockerHub credentials in your Jenkins pipeline, follow these steps:
  - Go to "Dashboard" → "Manage Jenkins" → "Manage Credentials."
  - Click on "System" and then "Global credentials (unrestricted)."
  - Click on "Add Credentials" on the left side.
  - Choose "Secret text" as the kind of credentials.
  - Enter your DockerHub credentials (Username and Password) and give the credentials an ID (e.g., "docker").
  - Click "OK" to save your DockerHub credentials.

Now, you have installed the Dependency-Check plugin, configured the tool, and added Docker-related plugins along with your DockerHub credentials in Jenkins. You can now proceed with configuring your Jenkins pipeline to include these tools and credentials in your CI/CD process.

```groovy

pipeline {
    agent any
    tools {
        jdk 'jdk17'
        nodejs 'node16'
    }
    environment{
        SCANNER_PATH = tool 'SonarQube'
    }
    stages{
        stage('clean workspace'){
            steps{
                cleanWs()
            }
        }
        stage('code checkout'){
            steps{
                git branch:'master',url:'https://github.com/pr12sdd/DevSecOps-Project.git'
            }
        }
        stage('sonarqube analysis'){
            steps{
                withSonarQubeEnv('sonarqube') {
                sh "$SCANNER_PATH/bin/sonar-scanner -Dsonar.projectName=Netflix-clone -Dsonar.projectKey=Netflix-clone"
            }
        }
    }
        stage('Quality Gate'){
            steps{
                script{
                    waitForQualityGate abortPipeline:false , credentialsId: 'squ_b68070934401ab55478baa0482c7ee8f5c6e7823'
                }
            }
        }
        stage('Install Dependencies'){
            steps{
            sh 'npm install'
            }
        }
        stage('Dependencies Check'){
           steps {
               dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'Owaspp'
               dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
           }
        }
        stage('Trivy filesystem scan'){
            steps {
                sh 'trivy fs . > trivyfs.txt'
            }
        }
        stage('Docker build and push'){
            steps{
                script {
                    withDockerRegistry([credentialsId : 'dockerhub',toolName : 'dockerhub',url: '']){
                        sh 'docker build --build-arg VITE_APP_TMDB_V3_API_KEY=faadc7bf6985b705d165fcdc5316c9c0 -t netflix-clone:latest .'
                        sh 'docker image tag netflix-clone:latest pkmadhubani/netflix-clone:latest'
                        sh 'docker push pkmadhubani/netflix-clone:latest'
                    }
                  
            }
        }
        }
        stage('Trivy image scan'){
            steps{
            sh 'trivy image pkmadhubani/netflix-clone:latest > trivyimagescan.txt'
            }
        }
        stage('Deploy to container'){
            steps{
            sh 'docker run -d -p 80:80 pkmadhubani/netflix-clone:latest'
            }
        }
}

post{
    always {
        emailext attachLog:true,
          subject:"'${currentBuild.result}'",
          body: """Project:${env.JOB_NAME}<br/>
                   BuildNumber:${env.BUILD_NUMBER}<br/>
                   URL:${env.BUILD_URL}<br/>""",
          to: 'prakashkumar5332@gmail.com',
          attachmentsPattern: 'trivyfs.txt,trivyimagescan.txt'
    }
}
}

If you get docker login failed errorr

sudo su
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins


```
### **Phase 4: Deploying Application to kubernetes and integrate with ArgoCD**
  - This downloads the latest release for your system architecture:
    ```bash
    curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_arm64.tar.gz
    ```
  - After downloading, extract the binary and move it to a directory in your PATH. For example:
    ```bash
    sudo mv /tmp/eksctl /usr/local/bin   
    ```
  - Verify the installation with:
    ```bash
    eksctl version
    ```
  - Create ekscluster with:
    ```bash
    eksctl create cluster --name=cluster_name --region=region_name --without-nodegroup
    ```
  - To associate an OpenID Connect (OIDC) provider with your Amazon EKS cluster:
    ```bash
    eksctl utils associate-iam-oidc-provider --cluster=cluster_name --region=region_name --approve
    ```
  - To create a nodegroup in your cluster:
    ```bash
    eksctl create nodegroup --name=nodegorup_name --cluster=cluster_name --region=region_name --nodes=no_of_nodes --nodes-max=no_of_max_nodes --nodes-min=no_of_min_nodes --node-volume-size=20 --node-type=t2.medium --managed --ssh-access --ssh-public-key=public-key-name
    ```
  - For updating the kubeconfig:
    ```bash
    aws eks update-kubeconfig --cluster=cluster_name --region=region-name
    ```
  - Deploying the Application to the Kubernetes Cluster:
    Now that your Amazon EKS cluster is fully provisioned, the nodegroup is running, and your kubeconfig is updated, you can deploy your pre-written Kubernetes YAML manifest files to the cluster using kubectl.
    First, confirm that you are connected to the correct cluster:
    ```bash
    kubectl get nodes
    ```
    This should return a list of nodes from your managed nodegroup.
  - Organize Your Manifest Files:
    Ensure all your Kubernetes YAML manifest files (e.g., Deployments, Services, ConfigMaps, Secrets, Ingress, etc.) are saved in a dedicated directory for easy management. For example:
    ```
    k8s/
    ├── deployment.yaml
    ├── service.yaml
    ├── configmap.yaml
    |── ingress.yaml
  - Apply the Manifests to the Cluster:
    ```bash
    kubectl apply -f k8s/
    ```
  - If you used a LoadBalancer Service, wait a few minutes for AWS to provision the load balancer. The EXTERNAL-IP field will update with the load balancer DNS name once ready.
You can then access your application at:
    ```
    http://<load-balancer-dns-name>
    ```
### Deploy Application with ArgoCD

**Step 1: Install ArgoCD:**

   You can install ArgoCD on your Kubernetes cluster by following the instructions provided in the [EKS Workshop](https://archive.eksworkshop.com/intermediate/290_argocd/install/) documentation.

**Step 2: Set Your GitHub Repository as a Source:**

   After installing ArgoCD, you need to set up your GitHub repository as a source for your application deployment. This typically involves configuring the connection to your repository and defining the source for your ArgoCD application. The specific steps will depend on your setup and requirements.

**Step 3: Create an ArgoCD Application:**
   - `name`: Set the name for your application.
   - `destination`: Define the destination where your application should be deployed.
   - `project`: Specify the project the application belongs to.
   - `source`: Set the source of your application, including the GitHub repository URL, revision, and the path to the application within the repository.
   - `syncPolicy`: Configure the sync policy, including automatic syncing, pruning, and self-healing.

**Step 4: Access your Application**
   - To Access the app make sure port 30007 is open in your security group and then open a new tab paste your NodeIP:30007, your app should be running.
    
    
### **Phase 5: Monitoring**

**Step 1: Install Prometheus and Grafana:**

   Set up Prometheus and Grafana to monitor your application.

   **Installing Prometheus:**

   - Add the Prometheus Community Helm repository:
     ```bash
     helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
     ```
   - Update your Helm repositories to fetch the latest chart information:
     ```bash
     helm repo update
     ```
   - Install the kube-prometheus-stack chart in a new namespace (e.g., monitoring):
     ```bash
     kubectl create namespace monitoring
     helm install prometheus-stack prometheus-community/kube-prometheus-stack --namespace monitoring
     ```
     This single command installs Prometheus, Grafana, Alertmanager, and necessary exporters (like node-exporter and kube-state-metrics).
   - Verify the installation by checking the status of the pods. It may take a few minutes for all pods to be in the Running state:
     ```bash
     kubectl get pods --namespace monitoring
     ```
   ### OR
   - We can also install it using kubectl:
     ```bash
     sudo useradd --system --no-create-home --shell /bin/false prometheus
     wget https://github.com/prometheus/prometheus/releases/download/v2.47.1/prometheus-2.47.1.linux-amd64.tar.gz
     ```
   ***Accessing Grafana:***
   Once the pods are running, you can access the Grafana dashboard via port forwarding for temporary access or configure a permanent method like a LoadBalancer or Ingress.
   - Retrieve the default admin password for Grafana:
     ```bash
     kubectl get secret --namespace monitoring prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
     ```
   - Use kubectl port-forward to access the Grafana UI from your local machine (opens Grafana on http://localhost:3000):
     ```bash
     kubectl port-forward --namespace monitoring service/prometheus-stack-grafana 3000:80
     ```
     Keep this terminal window open while you use Grafana.
   ***Login to Grafana***
   - Open your web browser and navigate to http://localhost:3000.
   - Log in with the username admin and the password you retrieved with the command above. You may be prompted to change the passwor

**Step 2: Add Prometheus Data Source:**

To visualize metrics, you need to add a data source. Follow these steps:

- Click on the gear icon (⚙️) in the left sidebar to open the "Configuration" menu.

- Select "Data Sources."

- Click on the "Add data source" button.

- Choose "Prometheus" as the data source type.

- In the "HTTP" section:
  - Set the "URL" to `http://localhost:9090` (assuming Prometheus is running on the same server).
  - Click the "Save & Test" button to ensure the data source is working.

**Step 3: Import a Dashboard:**

To make it easier to view metrics, you can import a pre-configured dashboard. Follow these steps:

- Click on the "+" (plus) icon in the left sidebar to open the "Create" menu.

- Select "Dashboard."

- Click on the "Import" dashboard option.

- Enter the dashboard code you want to import (e.g., code 1860).

- Click the "Load" button.

- Select the data source you added (Prometheus) from the dropdown.

- Click on the "Import" button.

You should now have a Grafana dashboard set up to visualize metrics from Prometheus.

Grafana is a powerful tool for creating visualizations and dashboards, and you can further customize it to suit your specific monitoring needs.

That's it! You've successfully installed and set up Grafana to work with Prometheus for monitoring and visualization.

### **Phase 6: Notification**

1. **Implement Notification Services:**
    - Set up email notifications in Jenkins or other notification mechanisms.

### **Phase 7: Cleanup**

1. **Cleanup AWS EC2 Instances:**
    - Terminate AWS EC2 instances that are no longer needed.
