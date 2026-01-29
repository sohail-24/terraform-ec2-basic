# 🚀 Terraform EC2 – Production Ready (SSM + Optional SSH)

This repository demonstrates **production-ready Infrastructure as Code (IaC)** using **Terraform on AWS**.

It provisions:

* An EC2 instance
* IAM Role with **AWS SSM Session Manager** access (secure, no SSH keys required)
* Optional SSH access (for learning / non-production)
* Parameterized, secure, Git-friendly infrastructure

> **Core principle:**
> Terraform provisions infrastructure.
> Ansible configures servers (next phase).
> No AWS Console clicks.

---

## 🧱 Architecture Overview

* **Terraform** → Infrastructure provisioning
* **AWS IAM + SSM** → Secure access (no port 22 required)
* **Git** → Single source of truth
* **Ansible (next step)** → OS, Docker, Kubernetes automation

---

## 📁 Repository Structure

```
terraform-ec2-basic/
├── main.tf
├── provider.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
├── versions.tf
├── .gitignore
└── README.md
```

---

## ✅ One-Time Local Requirements

These tools run on **your local machine or CI runner**.
Terraform **does not install tools on your laptop** (this is intentional and industry standard).

---

## 🖥️ Local Setup – macOS & Windows

### 🔹 macOS (Homebrew)

Install **all required tools in one command**:

```bash
brew install terraform awscli ansible && brew install --cask session-manager-plugin
```

---

### 🔹 Windows (PowerShell – Recommended)

> Run **PowerShell as Administrator**

#### 1️⃣ Install Chocolatey (one-time)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force;
[System.Net.ServicePointManager]::SecurityProtocol = 3072;
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

Restart PowerShell after installation.

---

#### 2️⃣ Install required tools

```powershell
choco install terraform awscli ansible session-manager-plugin -y
```

Verify:

```powershell
terraform -version
aws --version
ansible --version
session-manager-plugin --version
```

---

### 🔹 Alternative (Windows without Chocolatey)

You can manually install:

* Terraform → [https://developer.hashicorp.com/terraform/downloads](https://developer.hashicorp.com/terraform/downloads)
* AWS CLI → [https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* Session Manager Plugin → [https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)

---

## 🔐 AWS Authentication

Configure AWS credentials (one-time):

```bash
aws configure
```

Verify:

```bash
aws sts get-caller-identity
```

---

## 🚀 How to Use This Project

### 1️⃣ Clone the repository

```bash
git clone https://github.com/sohail-24/terraform-ec2-basic.git
cd terraform-ec2-basic
```

---

### 2️⃣ Review configuration

Edit `terraform.tfvars` if required:

```hcl
aws_region    = "ap-south-1"
instance_type = "t3.small"
ami_id        = "ami-0ff5003538b60d5ec"
instance_name = "prod-ready-ec2"
volume_size   = 30
enable_ssh    = true
```

> 💡 In real production environments:

```hcl
enable_ssh = false
```

---

### 3️⃣ Initialize Terraform

```bash
terraform init
```

---

### 4️⃣ Review the execution plan

```bash
terraform plan
```

---

### 5️⃣ Apply infrastructure

```bash
terraform apply
```

---

## 🔑 Accessing the EC2 Instance (Production Way)

This project uses **AWS SSM Session Manager** by default.

After `terraform apply`, Terraform outputs:

```text
ssm_command = aws ssm start-session --target <instance-id>
```

Run it:

```bash
aws ssm start-session --target <instance-id>
```

✅ No SSH keys
✅ No inbound ports
✅ Fully audited access

---

## ❓ Why SSH Does Not Work by Default

* Private SSH keys are **never stored in Git**
* Terraform uploads **only the public key**
* This is **intentional and production-safe**

In production, **SSM replaces SSH entirely**.

---

## 🧠 Design Decisions (Interview-Ready)

* SSH is **optional and disabled by default**
* IAM Roles are used instead of static credentials
* Default VPC and subnets are dynamically discovered
* Infrastructure and configuration are cleanly separated

> “Infrastructure is provisioned using Terraform, while OS and application configuration is handled later via Ansible.”

---

## 🧹 Cleanup

```bash
terraform destroy
```

> ⚠️ `prevent_destroy` may be enabled in production for safety.

---

## 🔜 Next Steps

* ✅ Terraform infrastructure (completed)
* 🔜 Ansible automation

  * Docker installation
  * kubeadm, kubelet, kubectl
  * Kubernetes bootstrap
* 🔜 CI/CD & GitOps

---

## 👤 Author

**Mohammed Sohail**
DevOps Engineer
AWS • Terraform • Kubernetes • Ansible
