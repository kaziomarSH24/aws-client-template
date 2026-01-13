## AWS EC2 Terraform Template for Laravel / Docker

Production-ready Terraform configuration to provision a secure Ubuntu 24.04 LTS EC2 instance on AWS, preconfigured with Docker, Docker Compose, and Git. Designed so anyone can clone, update a few values, and create an instance safely.

---

## Features

- **Latest Ubuntu 24.04 LTS** AMI (automatic lookup via data source)
- **Security-first setup**
  - SSH access locked to your IPs only
  - Encrypted gp3 root EBS volume
  - HTTP (80) and HTTPS (443) open to the internet
- **Docker ready** on first boot (via EC2 user-data script)
- **Static IP (Elastic IP)** attached to the instance
- **Configurable** instance type, disk size, region, and tags

---

## Project Structure

```text
├── main.tf          # Core resources: EC2, Security Group, Key Pair, EIP
├── variables.tf     # Input variables and defaults
├── provider.tf      # AWS provider configuration
├── outputs.tf       # Useful outputs (public IP, SSH command)
├── terraform.tfvars # Your environment-specific values (NOT committed)
└── README.md        # Documentation
```

---

## Prerequisites

Before you start, make sure you have:

- **AWS Account** with permission to create EC2, EIP, and Security Groups
- **Terraform** installed (v1.x recommended)
- **AWS CLI** installed and configured with credentials:
  - `aws configure`
- **SSH key pair** on your local machine (used to log in to the instance)
  - Check if you already have one (Linux/macOS/WSL): `cat ~/.ssh/id_rsa.pub`
  - On Windows (PowerShell), your key is typically at: `C:\Users\<username>\.ssh\id_rsa.pub`
  - Generate one if needed: `ssh-keygen -t rsa -b 4096`

---

## Configuration (terraform.tfvars)

All user-specific settings are controlled via `terraform.tfvars` in the project root.

### Key Variables

| Variable          | Description                                         | Example                      | Required                     |
| ----------------- | --------------------------------------------------- | ---------------------------- | ---------------------------- |
| `project_name`    | Name used for tagging AWS resources                 | `"Laravel-Boilerplate-Prod"` | Yes                          |
| `aws_region`      | AWS region for deployment                           | `"ap-southeast-1"`           | No (default in variables.tf) |
| `instance_type`   | EC2 instance type                                   | `"t3.small"`                 | No (default)                 |
| `volume_size`     | Root EBS volume size in GB                          | `30`                         | No (default)                 |
| `public_key_path` | Local path to your **public** SSH key (`.pub` file) | `"~/.ssh/id_rsa.pub"`        | No (default)                 |
| `allowed_ssh_ips` | List of CIDR IPs allowed to SSH (port 22)           | `["203.0.113.10/32"]`        | Yes                          |

### Example terraform.tfvars

```hcl
# 1. Project Identifier
project_name = "Laravel-Boilerplate-Prod"

# 2. Target Region (Singapore)
aws_region   = "ap-southeast-1"

# 3. Server Specs
instance_type = "t3.small"
volume_size   = 30

# 4. SSH Key Path
# Linux / macOS / WSL example:
# public_key_path = "~/.ssh/id_rsa.pub"
# Windows example:
# public_key_path = "C:/Users/your-user/.ssh/id_rsa.pub"
public_key_path = "~/.ssh/id_rsa.pub"

# 5. Security Whitelist (Replace with your actual IPs)
allowed_ssh_ips = [
    "103.xx.xx.xx/32", # Your IP
    "45.xx.xx.xx/32"   # Optional: Client / teammate IP
]
```

> **Important:** `allowed_ssh_ips` **must** contain at least one valid IP/CIDR, otherwise you will not be able to SSH into the server.

---

## Usage

### 1. Clone the repository

```bash
git clone <your-repo-url>
cd aws-client-template
```

### 2. Create / edit terraform.tfvars

Update `terraform.tfvars` with your project name, region, SSH key path, and allowed SSH IPs (see example above).

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review the plan

```bash
terraform plan
```

Check that:

- Resources look as expected (1 EC2 instance, 1 EIP, 1 Security Group, key pair)
- Region, instance type, and volume size are correct

### 5. Apply and create the infrastructure

```bash
terraform apply
```

Type `yes` when prompted.

Terraform will:

- Create a key pair in AWS using your local public key
- Create a security group with restricted SSH and open HTTP/HTTPS
- Launch an Ubuntu 24.04 EC2 instance
- Attach an encrypted gp3 root volume
- Allocate and associate an Elastic IP
- Run a user-data script that installs Docker, Docker Compose, and Git

---

## Connecting to the Server

After `terraform apply` completes, Terraform will output:

- `server_public_ip` – the static Elastic IP
- `ssh_connection_string` – a ready-to-use SSH command

Example:

```bash
ssh ubuntu@<YOUR_ELASTIC_IP>
```

Wait ~1–2 minutes after instance creation so the user-data script can finish installing Docker.

### Verify Docker installation

```bash
docker --version
docker compose version
```

---

## Clean Up (Destroy)

To remove all resources created by this template and stop AWS charges:

```bash
terraform destroy
```

Type `yes` to confirm. This will delete the EC2 instance, EIP, key pair, and security group created by this configuration.

---

## Security Notes

- **Never** commit `terraform.tfvars`, `.tfstate`, or `.tfstate.backup` files to GitHub.
- Restrict SSH (port 22) to **only** your trusted IP addresses via `allowed_ssh_ips`.
- Root EBS volume is encrypted using gp3 by default for better security and performance.
- Rotate SSH keys and review security group rules periodically.

---

## Next Steps (Laravel / Docker)

This template provisions a clean, Docker-ready Ubuntu server. Typical next steps for a Laravel project:

- Clone your Laravel application repo onto the server
- Add your `docker-compose.yml` / deployment scripts
- Configure environment variables and database connections

You can customise the user-data script in `main.tf` to automatically clone and run your application on first boot if desired.

---

## License

This project is open-source software licensed under the MIT license.
