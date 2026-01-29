# 🚀 Terraform EC2 – Production Ready (Remote State with S3 + DynamoDB)

This repository demonstrates **real-world, production-grade Terraform practices** used by DevOps teams in companies.

It provisions:

* ✅ EC2 instance
* ✅ IAM Role with **AWS SSM Session Manager** (NO SSH)
* ✅ Remote Terraform state using **S3**
* ✅ State locking using **DynamoDB**
* ✅ Clean, Git-safe, team-ready setup

> **Core Rule**
> Terraform provisions infrastructure.
> Ansible configures servers (next phase).
> No AWS Console clicking. No SSH keys in Git.

---

## 🧱 Architecture Overview

```
Developer / CI
     |
Terraform CLI
     |
S3 (terraform.tfstate)  ← State storage
DynamoDB (lock table)   ← Prevents parallel runs
     |
AWS APIs
     |
EC2 + IAM + Security Groups
```

---

## 📁 Repository Structure

```
terraform-ec2-basic/
├── backend.tf          # S3 + DynamoDB backend
├── main.tf             # EC2, IAM, Security Group
├── provider.tf         # AWS provider
├── variables.tf        # Input variables
├── terraform.tfvars    # Environment values
├── outputs.tf          # Safe outputs only (NO SSH)
├── versions.tf         # Terraform/provider versions
├── .gitignore
└── README.md
```

---

## 🔐 Why Remote State (S3 + DynamoDB)?

### ❌ Local state problems

* State exists only on one laptop
* Team members overwrite each other
* No locking
* Easy to lose infrastructure history

### ✅ Production solution

| Component    | Purpose                                          |
| ------------ | ------------------------------------------------ |
| **S3**       | Stores `terraform.tfstate` centrally             |
| **DynamoDB** | Locks state (only ONE terraform apply at a time) |

This is **mandatory in companies**.

---

## 📦 What Is Stored in Terraform State?

⚠️ **IMPORTANT:**
Terraform state does **NOT** store application data.

It stores **infrastructure metadata**, such as:

* EC2 instance ID
* Security Group IDs
* IAM Role ARNs
* Subnet IDs
* Volume sizes
* Public/Private IPs
* Resource dependencies

### ❓ Why companies store this?

Terraform needs state to:

* Know **what already exists**
* Know **what to change**
* Know **what to destroy**
* Prevent duplicate resources
* Maintain infrastructure consistency

> **State = Terraform’s memory**

---

## ❌ What Is NOT Stored?

Terraform state does **NOT** store:

* Application data
* Database data
* Files inside EC2
* Logs
* User data

Those belong to:

* Databases
* S3 app buckets
* EBS volumes
* Logging systems

---

## 🪣 S3 Bucket Naming (Important Concept)

S3 bucket names are **globally unique**.
You do **NOT** create a bucket per user

### ❓ What if multiple users work together?

✅ **Correct production approach**

* ONE shared bucket
* ONE DynamoDB table
* Multiple environments via **keys or workspaces**

Example:

```
terraform/dev/terraform.tfstate
terraform/prod/terraform.tfstate
```

You **do NOT** create new buckets per user.

---

## 🖥️ One-Time Local Requirements

### macOS (Homebrew)

```bash
brew install terraform awscli ansible
brew install --cask session-manager-plugin
```

### Windows (PowerShell – Admin)

```powershell
choco install terraform awscli ansible session-manager-plugin -y
```

Verify:

```bash
terraform -version
aws --version
ansible --version
session-manager-plugin --version
```

---

## 🔐 AWS Authentication (One Time)

```bash
aws configure
aws sts get-caller-identity
```

---

## 🧱 Backend Setup (IMPORTANT)

### ⚠️ Do I need to create S3 & DynamoDB every time?

**NO. ABSOLUTELY NOT.**

### ✅ Create ONCE per account/environment

Terraform will reuse them forever.

#### S3 Bucket (once)

```bash
aws s3api create-bucket \
  --bucket sohail-terraform-state-prod \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1
```

```bash
Enable versioning (VERY IMPORTANT):

aws s3api put-bucket-versioning \
  --bucket sohail-terraform-state-prod \
  --versioning-configuration Status=Enabled
```

#### ✅ Create DynamoDB Lock Table (ONE TIME)

```bash
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-south-1
```

Terraform then **automatically uses them**.

---

## 🚀 Using This Project

### 1️⃣ Clone

```bash
git clone https://github.com/sohail-24/terraform-ec2-basic.git
```

```bash
cd terraform-ec2-basic
```

### 2️⃣ Initialize (first time or backend change)

```bash
terraform init -reconfigure
```

### 3️⃣ Plan

```bash
terraform plan
```

### 4️⃣ Apply

```bash
terraform apply
```

---

## 🔑 Accessing EC2 (Production Way)

This project uses **AWS SSM Session Manager**.

```bash
aws ssm start-session --target <instance-id>
```

✅ No SSH
✅ No port 22
✅ Fully audited
✅ Enterprise-grade security

---

## ❌ Why SSH Is Removed

* SSH keys leak
* Keys get copied
* No audit trail
* Not zero-trust

**SSM replaces SSH in production.**

---

## 🧹 Cleanup (IMPORTANT)

### Destroy Infrastructure

```bash
terraform destroy
```

### ❓ What happens after destroy?

| Resource        | Deleted? |
| --------------- | -------- |
| EC2             | ✅ Yes    |
| Security Groups | ✅ Yes    |
| IAM Role        | ✅ Yes    |
| Terraform State | ❌ NO     |
| S3 Bucket       | ❌ NO     |
| DynamoDB Table  | ❌ NO     |

👉 **State backend stays intentionally**

---

## 🗑️ Delete Backend (ONLY if project is finished)

⚠️ **Danger zone – do this only if you are DONE**

Because S3 versioning is enabled, **you must delete ALL versions.**

**Step 1: Delete ALL object versions**

```bash
aws s3api list-object-versions \
 --bucket sohail-terraform-state-prod \
 --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}' \
 --output json > versions.json
```

```bash
aws s3api delete-objects \
  --bucket sohail-terraform-state-prod \
  --delete file://versions.json
```
**Step 2: Delete bucket**

```bash
aws s3 rb s3://sohail-terraform-state-prod
```
**Step 3: Delete DynamoDB table**

```bash
aws dynamodb delete-table \
  --table-name terraform-locks \
  --region ap-south-1
```

---

## 🧠 Interview-Ready Summary

> “We use S3 to store Terraform state centrally and DynamoDB for state locking to avoid concurrent changes.
> Terraform state stores infrastructure metadata, not application data.
> SSM replaces SSH for secure, auditable access.
> Infrastructure provisioning and configuration are cleanly separated.”

---

## 🔜 Next Phase

✅ Terraform (completed)
🔜 **Ansible automation**

* Docker
* Kubernetes
* App deployment

---

👤 **Author**
**Mohammed Sohail**
DevOps Engineer
AWS • Terraform • Kubernetes • Ansible
