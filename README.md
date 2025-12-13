# 🚀 Terraform AWS CI/CD Pipeline Project

A complete DevOps project demonstrating the provisioning of secure, modular infrastructure on **Amazon Web Services (AWS)** using **Terraform** and automating the deployment via **GitHub Actions CI/CD pipeline**.

## 🌟 Project Goals and Achievements

This project successfully implemented modern DevOps practices focusing on security, scalability, and automation.

| Feature | Technology Used | Achievement |
| :--- | :--- | :--- |
| **Infrastructure as Code (IaC)** | Terraform | Defined and managed all AWS resources in code (HCL). |
| **CI/CD Automation** | GitHub Actions | Automated the `init`, `plan`, and `apply` workflow on every push to the `main` branch. |
| **Modular Design** | Terraform Modules | Created reusable code (`modules/ec2-basic`) for simplified scaling and resource definition (Task 5). |
| **State Management** | AWS S3 & DynamoDB | Implemented a highly secure, versioned, and encrypted remote backend with state locking (Task 7). |
| **Environment Separation** | Terraform Workspaces | Used workspaces (`dev`, `stage`) to manage completely isolated infrastructure environments (Task 8). |

## 🛠️ Technologies Used

| Category | Technology | Purpose |
| :--- | :--- | :--- |
| **Infrastructure** | [cite_start]**Terraform (HCL)** [cite: 4] | Core IaC tool for defining and provisioning resources. |
| **Cloud Provider** | **AWS** | Target environment for all deployed infrastructure (EC2, S3, DynamoDB). |
| **Source Control** | [cite_start]**Git & GitHub** [cite: 22] | Repository hosting and source code management. |
| **Automation** | [cite_start]**GitHub Actions** [cite: 28] | Orchestrates the automated CI/CD pipeline. |
| **State Backend** | **AWS S3** | Remote storage for the Terraform state file (`terraform.tfstate`). |
| **State Locking** | **AWS DynamoDB** | Prevents concurrent state file modifications and corruption. |

## 🔑 AWS Prerequisites (Manual Setup)

Before running the pipeline, these critical backend resources must be manually created in your AWS account (`us-east-1` region).

1.  **Create State Bucket (S3):**
    * **Name:** `gqadir-tf-state-lock-2025` (Must be unique)
    * **Required Features:** Bucket Versioning and Default Encryption (SSE-S3) must be enabled.
2.  **Create Lock Table (DynamoDB):**
    * **Name:** `terraform-state-lock-table`
    * **Primary Key:** `LockID` (Type: String) **(No Sort Key)**

## 🚀 How to Use the Pipeline

### 1. Configure GitHub Secrets

The CI/CD pipeline requires secure access to your AWS account. You must configure the following secrets in your GitHub repository (**Settings > Security > Secrets and variables > Actions**):

| Secret Name | Value |
| :--- | :--- |
| `AWS_ACCESS_KEY_ID` | Access Key of the `terraform-cli-user` [cite: 52] |
| `AWS_SECRET_ACCESS_KEY` | [cite_start]Secret Key of the `terraform-cli-user` [cite: 53] |

### 2. Initialize the Local Repository

Clone the project and initialize Terraform to connect to the remote backend.


# Clone the repository
git clone <repository_url>
cd terraform-devops-project

# Initialize the backend and providers
terraform init


3. Deploy the dev EnvironmentTo deploy the Development environment, you must create and select the dev workspace.Bash# 1. Create the dev workspace (this requires the DynamoDB lock table to work!)
terraform workspace new dev

# 2. Push the code to GitHub (Triggering the pipeline)
# The pipeline will automatically run 'terraform apply' to deploy the two EC2 servers.
git add .
git commit -m "feat: Deploying infrastructure to dev environment"
git push
4. Deploy the stage Environment (Promotion)To deploy the next isolated environment, switch the workspace and push any code change.Bash# 1. Switch to the stage workspace
terraform workspace new stage

# 2. Push a code change (e.g., changing the instance type in main.tf)
git add .
git commit -m "fix: Promoting modular code to stage environment"
git push
5. Cleanup (Destroy Resources)To avoid incurring AWS costs, always select the environment and destroy the resources.Bash# 1. Select the environment you want to destroy
terraform workspace select dev 

# 2. Destroy all resources in that environment
terraform destroy
# Type 'yes' when prompted to confirm the deletion.
👨🏻‍💻 Author and Contact InformationDetailsValueAuthor NameGhulam QadirTitleIT StudentEmail📧 gqitspecialist@gmail.comLinkedIn🔗 https://www.linkedin.com/in/ghulam-qadir-07a982365Portfolio🌐 https://ghulam-qadir.netlify.app/Instagram📸 https://www.instagram.com/coreit.techFacebook📘 https://www.facebook.com/share/1AmgLDUnc9/YouTube🎥 https://www.youtube.com/channel/UCMzACb-lwCjc7GGw6vsYUdQ
