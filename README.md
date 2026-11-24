# AWS CloudOps Internship Project

**Monitored two-tier web application on AWS with incident, change, and problem handling**

This project is a hands-on CloudOps lab for provisioning, monitoring, and troubleshooting a web application backed by a private PostgreSQL database. It combines Terraform infrastructure-as-code with operational practices such as monitoring, alerting, patch planning, incident runbooks, and cost controls.

> **Project status:** This repository contains infrastructure configuration and an application deployment package's source files. Terraform syntax and formatting checks have passed locally. An end-to-end browser-to-database test has **not** yet been confirmed here. Some operations remain subject to mentor approval and cost controls.

## Architecture

```text
                   Internet / browser
                            |
                            v
               Application Load Balancer
                    (public subnets)
                            |
                            v
                     Target group
                            |
                            v
                  Auto Scaling Group
               (Windows EC2 instances)
                    (private subnets)
                            |
                            v
                    Flask application
                            |
                            v
                  Amazon RDS PostgreSQL
                    (private database)
```

The configuration distributes application instances across two private subnets. The Auto Scaling Group currently specifies a minimum of **0**, maximum of **2**, and desired capacity of **1**. These are configuration values, not a claim about live instance count.

## AWS services and operational components

| Area | Components / purpose |
| --- | --- |
| Networking | VPC, public and private subnets, routing, security groups |
| Application | Application Load Balancer, target group, Windows EC2 launch template and Auto Scaling Group |
| Database | Amazon RDS for PostgreSQL in a private network |
| Access and security | IAM, AWS Systems Manager, AWS Secrets Manager configuration, security groups |
| Observability | Amazon CloudWatch dashboard and alarm configuration; Amazon SNS notifications |
| Audit | AWS CloudTrail with an S3 destination |
| Cost management | AWS Budget alerts and lab shutdown/cost-control procedures |
| Maintenance | AWS Systems Manager Patch Manager baseline and maintenance-window planning |

These components are at different stages of configuration and verification. A configured resource should not be assumed healthy or currently running without checking AWS.

## Repository structure

```text
bootstrap/                     Terraform configuration for infrastructure prerequisites
terraform/                     Main infrastructure as code
  compute.tf                   Windows EC2 launch template and Auto Scaling Group
  network.tf                   VPC and subnet networking
  loadbalancer.tf              ALB and target group
  database.tf                  PostgreSQL database resources
  iam.tf                       IAM configuration
  security.tf                  Security groups and related rules
  outputs.tf                   Terraform outputs
  iis-userdata.xml             Windows instance bootstrap configuration
  alarms.tf.example            Monitoring example (not active .tf configuration)
  monitoring.tf.example        Monitoring example (not active .tf configuration)
  patching.tf.example          Patching example (not active .tf configuration)
deployment/
  app_rds.py                   Flask application version included in the local deployment ZIP
  run_private_app.py           Application runner
  requirements-deploy.txt      Python deployment dependencies
  schema.sql                   Database schema definition
.gitignore                     Exclusions for local state, secrets, and deployment artifacts
```

Historical drafts, local backups, generated ZIP files, and temporary test artifacts are intentionally excluded from this source snapshot.

## Application and data flow

The intended request path is **browser → ALB → Windows EC2 / Flask → private RDS PostgreSQL**. The application's source is in `deployment/app_rds.py`. A local deployment ZIP was checked and matched this version exactly; that comparison does **not** independently prove the version currently running on EC2.

**End-to-end verification still required:** submit a test record through the web form, confirm a successful application response, and query the private PostgreSQL database through an approved secure access path to verify the saved record. Avoid posting personal data or database credentials in test evidence.

## Terraform workflow

Prerequisites include Terraform, AWS CLI authentication for the **lab account**, and access to the required backend and local configuration. Review the plan carefully before making changes.

```powershell
terraform -chdir=terraform fmt -check
terraform -chdir=terraform validate
terraform -chdir=terraform plan
```

**Do not run `terraform apply` automatically.** Confirm the account, region, budget, planned changes, and required mentor approvals first. Never use production AWS credentials for this lab.

### Local-only Secrets Manager configuration

`terraform/secrets.tf` is intentionally **not included in Git**. In the local working directory it contains Secrets Manager and IAM policy resources. It must be retained locally as-is unless a reviewed change is approved. A fresh clone may therefore be **incomplete for deployment** until the needed non-secret infrastructure definitions and secure secret provisioning are supplied through an approved process. No passwords, state files, credentials, or secret values should be committed.

## Monitoring, operations, and safety

- Review CloudWatch alarms, dashboard metrics, and SNS notifications when troubleshooting; verify actual alarm states in AWS.
- Use CloudTrail for audit trails and change investigations.
- Treat patch schedules and operational examples as documentation until enabled and verified.
- Record incident symptoms, investigation, evidence, action taken, and next steps in runbooks or tickets.
- Keep idle lab compute resources stopped where appropriate, and inspect AWS Budget and remaining credits before deploying billable infrastructure.
- Check changes with `terraform plan` and obtain approval where required; do not perform unapproved production changes.

## Verification checklist

- [x] Local Terraform configuration passed `terraform validate`.
- [x] Local Terraform configuration passed `terraform fmt -check`.
- [x] Git patch check passed with no reported whitespace errors.
- [x] Local deployment ZIP's `app_rds.py` matched `deployment/app_rds.py`.
- [ ] Verify the currently running EC2 application version.
- [ ] Verify ALB target health and application readiness.
- [ ] Submit a browser form and confirm its record in private RDS PostgreSQL.
- [ ] Review remaining operational tasks and mentor approvals.
- [ ] Document the final verified demonstration and incident/change/problem runbooks.

## Scope

This repository is a learning and demonstration project, **not** a production-ready deployment template. Availability, patching, IAM privileges, data handling, and infrastructure costs need further review before any broader use.
