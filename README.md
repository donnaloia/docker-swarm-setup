# AWS Docker Swarm Setup

This repository contains a Terraform template for quickly setting up a Docker Swarm on EC2 instances. The template creates the necessary cloud infrastructure and configures the EC2 instances to form a Docker Swarm, enabling distributed container deployment and basic container orchestration.

## Features

- Spins up vanilla EC2 instances.
- Configures the necessary cloud infrastructure underneath including VPCs and security groups.
- Sets up Docker Swarm on the EC2 instances for distributed container deployment.

## Dependencies
- terraform 
- jq 

## Setup
If you are new to using Terraform with the AWS provider, Terraform uses the AWS SDK for Go behind the scenes, which automatically checks environment variables for AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY

This means that 1.  Defining these variables in the terraform template is not required and 2.  Setting your own AWS credentials as environment variables is a requirement to run this.  See example below

```bash
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
```

## Usage

```bash
terraform init apply && terraform apply
```

## Confirm it worked

ssh into the ec2 instance hosting the swarm manager and run the following:

```bash
docker node ls
```

## Design Tradeoffs
- Swarmifying ec2 instances manually via shell scripts adds complexity and introduces more IAC to manage over just using the existing swarm-aws terraform module
- An argument could be made that configuring ec2 instances to join docker swarm might be better handled by ansible or another config management tool.
- Advanced container orchestration becomes complicated without the use of Kubernetes or a comparable orchestration tool
- Using Fargate and ECS in conjunction with other AWS services could offer the same functionality with less overhead

## Future Improvements
- Automate the addition of each Swarm node IP to an AWS discovery pool (Cloud Map).
- Create an API Gateway resource via the Terraform template that points to the discovery pool. This will allow the API Gateway to load balance among the Swarm nodes without us having to manually update the config each time a new EC2 instance is spun up
- Remove jq dependency 