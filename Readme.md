# AWS Transit Gateway with 3 VPCs (WebApp, SharedDatabase, BackendServices)

This project demonstrates how to interconnect **three VPCs** (WebApp, SharedDatabase, and BackendServices) using an **AWS Transit Gateway (TGW)**.  
Each VPC has an EC2 instance deployed in its subnet, and connectivity between them is tested via **SSH and cURL**.

---

##  Architecture Overview
- **VPCs:**
  - `webapp` VPC (with public subnet for SSH access)  
  - `shareddatabase` VPC (private subnet)  
  - `backendservices` VPC (private subnet)  
- **Transit Gateway:** Connects all three VPCs.  
- **EC2 instances:**
  - Ubuntu AMI with Nginx installed.  
  - One instance in each VPC subnet.  

---

##  Setup Steps

### 1. Deploy Infrastructure with Terraform
Clone the repository and apply Terraform:

```bash
terraform init
terraform apply -auto-approve
```
This will create:

3 VPCs

Subnets and route tables

Transit Gateway + attachments

EC2 instances in each subnet

Security groups with SSH/HTTP rules

### 2. Verify Transit Gateway Attachments
Ensure all VPCs are attached to the Transit Gateway:

```bash
aws ec2 describe-transit-gateway-attachments \
  --filters Name=transit-gateway-id,Values=<your-tgw-id> \
  --query "TransitGatewayAttachments[*].{VPC:ResourceId,State:State}"
```
All should be in available state.

### 3. Check Route Tables
VPC Route Tables: Each VPC should have routes to the other VPC CIDRs via the TGW.

Transit Gateway Route Table: Must have entries for each VPC CIDR pointing to the correct attachment.

Example TGW routes:

10.10.0.0/16 → WebApp attachment
10.20.0.0/16 → SharedDatabase attachment
10.30.0.0/16 → BackendServices attachment
### 4. Security Groups
WebApp EC2 SG: allows SSH (22) from your IP.

SharedDatabase + BackendServices SGs: allow inbound HTTP (80) from WebApp VPC CIDR (10.10.0.0/16).

All SGs allow outbound traffic.

### 5. Connect to the WebApp Instance
Ensure your private key (terraform-key.pem) is in ~/.ssh with correct permissions:

```bash
chmod 400 ~/.ssh/terraform-key.pem
SSH into the WebApp EC2:
```

```bash
ssh -i ~/.ssh/terraform-key.pem ubuntu@<webapp_public_ip>
```
### 6. Get Private IPs of Other Instances
From your local machine:
```bash
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=SharedDatabase-Linux-Instance" \
  --query "Reservations[].Instances[].PrivateIpAddress" \
  --output text
```
Repeat for BackendServices.

### 7. Test Connectivity from WebApp EC2
Once inside the WebApp instance:

```bash
# Replace with actual private IPs
curl http://<shared-db-private-ip>
curl http://<backendservices-private-ip>
```
You should see the Nginx HTML page with hostname and private IP.

## Expected Results
You can SSH only into the WebApp EC2 (via public IP).

From inside WebApp, you can curl into the SharedDatabase and BackendServices EC2s using their private IPs.

Transit Gateway routes traffic between the 3 VPCs successfully.