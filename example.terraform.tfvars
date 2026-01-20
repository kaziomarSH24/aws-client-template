# 1. Project Identifier
project_name = "Tunem"

# 2. Target Region 
aws_region   = "us-east-1"

# 3. Server Specs
instance_type = "t3.medium"
volume_size   = 30

# 4. SSH Key Path (Run 'cat ~/.ssh/id_rsa.pub' to verify)
public_key_path = "~/.ssh/aws_terraform_key.pub"

# 5. Security Whitelist (Replace with your actual IP)

allowed_ssh_ips = [
    "103.xx.xx.xx/32",  # Replace this with your current IP
    # "45.xx.xx.xx/32"    # Optional: Add another IP here
]

