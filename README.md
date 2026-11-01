# AWS Infrastructure Deployment with Terraform

A highly available and secure AWS web infrastructure provisioned using Terraform.

## 1. Project Overview

This project demonstrates the deployment of a scalable and secure web application infrastructure on AWS using Infrastructure as Code (IaC).

The objective was to provision an environment across multiple Availability Zones while maintaining network isolation, controlled access between application layers, and automated infrastructure management through reusable Terraform modules.

The infrastructure is deployed in the AWS Mumbai region (`ap-south-1`).

## 2. Architecture & Design Decisions

The environment uses a custom VPC (`10.0.0.0/16`) across two Availability Zones, with six subnets.

| Subnet          | CIDR         | Purpose             |
| --------------- | ------------ | ------------------- |
| Public AZ-1     | 10.0.1.0/24  | ALB and NAT Gateway |
| Public AZ-2     | 10.0.2.0/24  | ALB and NAT Gateway |
| Private AZ-1    | 10.0.11.0/24 | Application EC2     |
| Private AZ-2    | 10.0.12.0/24 | Application EC2     |
| DB Private AZ-1 | 10.0.21.0/24 | RDS                 |
| DB Private AZ-2 | 10.0.22.0/24 | RDS                 |

Key design decisions:

- **One NAT Gateway per AZ:** Each application-private subnet uses its corresponding NAT Gateway, avoiding dependency on a single NAT Gateway for outbound connectivity across both AZs.
- **Dedicated database subnets:** Database resources are separated from application subnets, with independent route tables and no default internet route.
- **Private application instances:** EC2 instances do not receive public IP addresses. All inbound application traffic comes through the ALB.
- **Restricted security groups:** Communication between ALB, application and database layers is controlled using security group references rather than broad CIDR-based access.

## 3. Application Load Balancer & Compute

An internet-facing Application Load Balancer distributes HTTP traffic across EC2 instances running in private subnets.

| Component            | Configuration                  |
| -------------------- | ------------------------------ |
| Load Balancer        | Internet-facing ALB            |
| Listener             | HTTP : 80                      |
| Target Group         | HTTP : 80                      |
| Health Check         | `/`                            |
| EC2 Instance         | Ubuntu 24.04, t3.micro         |
| Auto Scaling Minimum | 2                              |
| Desired Capacity     | 2                              |
| Maximum Capacity     | 4                              |
| Instance Placement   | Private subnets across two AZs |

EC2 instances are initialized through a User Data script that installs Nginx and serves a simple `Hello World` page.

### Auto Scaling

CloudWatch alarms and scaling policies are configured based on average CPU utilization:

- Scale out when CPU exceeds 70% over a 5-minute period.
- Scale in when CPU falls below 30% over a 5-minute period.
- Each scaling action adjusts capacity by one instance, with a 300-second cooldown.

## 4. Database Layer

Amazon RDS for MySQL is deployed separately from the application layer.

| Configuration        | Value        |
| -------------------- | ------------ |
| Engine               | MySQL 8.4.11 |
| Instance Class       | db.t3.micro  |
| Storage              | 20 GiB gp3   |
| Multi-AZ             | Enabled      |
| Public Accessibility | Disabled     |
| Storage Encryption   | Enabled      |
| Backup Retention     | 1 day        |

**Development environment decisions:**

- RDS uses AWS-managed master credentials through Secrets Manager instead of storing passwords in Terraform code.
- The instance uses a small `db.t3.micro` class to keep development costs controlled.
- Backup retention is set to one day for this development deployment.
- Final snapshot creation is skipped during deletion, and deletion protection is disabled. These are intentional development-environment choices, not recommended defaults for production workloads.

## 5. Security & Access Management

Security is implemented using three dedicated security groups.

| Security Group | Inbound Access              |
| -------------- | --------------------------- |
| ALB            | HTTP 80 from the internet   |
| Web            | HTTP 80 only from ALB SG    |
| Database       | MySQL 3306 only from Web SG |

Additional security decisions:

- Direct SSH access to application instances is not permitted.
- EC2 instances use an IAM role and instance profile with `AmazonSSMManagedInstanceCore`.
- IMDSv2 is enforced through the EC2 launch template.
- Application instances can access external repositories through NAT using outbound HTTP/HTTPS.
- Database credentials are managed through AWS Secrets Manager.
- No AWS access keys or database passwords are embedded in User Data.

## 6. Terraform Structure

The configuration is organised into independent modules to keep infrastructure components manageable and reusable.

```text
aws-web-infrastructure/
│
├── main.tf
├── providers.tf
├── terraform.tf
├── variables.tf
├── outputs.tf
│
├── modules/
│   ├── network/
│   ├── security/
│   ├── iam/
│   ├── load-balancer/
│   ├── compute/
│   └── database/
│
└── scripts/
    └── userdata.sh
```

Each module handles a specific infrastructure responsibility:

- `network` – VPC, subnets, gateways and routing.
- `security` – ALB, application and database security groups.
- `iam` – EC2 IAM role and instance profile.
- `load-balancer` – Application Load Balancer, listener and target group.
- `compute` – Launch template, Auto Scaling Group and CloudWatch scaling policies.
- `database` – Multi-AZ Amazon RDS MySQL instance and database subnet group.

This modular structure keeps the root configuration simple and makes individual infrastructure components easier to maintain and extend.

## 7. Deployment Evidence

Screenshots documenting the deployed infrastructure and validation results have been retained separately and are intentionally excluded from this public repository to avoid unnecessarily exposing AWS account and resource-specific information.

Redacted evidence can be provided separately upon request.

---

**Technologies:** AWS | Terraform | EC2 | VPC | ALB | Auto Scaling | RDS | IAM | CloudWatch | Secrets Manager | Nginx
