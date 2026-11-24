
# ============================================================
# Prem's 1st CloudOps Internship Project
# ============================================================

# Project: Prem_intern_1st_project
# AWS Account: 140864474143
# AWS Region: us-east-1
# Managed By: Terraform

# Project Architecture:
# - VPC with public and private subnets
# - Internet Gateway and route tables
# - Security Groups
# - IAM role and instance profile for SSM
# - Windows EC2 Launch Template
# - Auto Scaling Group
# - Application Load Balancer
# - PostgreSQL RDS database

# Infrastructure Configuration:
# network.tf      - VPC, subnets and routing
# security.tf     - Security groups and firewall rules
# iam.tf          - EC2 IAM role and instance profile
# compute.tf      - Windows EC2 and Auto Scaling Group
# loadbalancer.tf - ALB, target group and listener
# database.tf     - PostgreSQL RDS database

# Note:
# AWS resources are defined in their respective .tf files.
# This file provides an overview of the project.
