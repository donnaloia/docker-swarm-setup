# Docker Swarm Setup

This repository contains a Terraform template for quickly setting up a Docker Swarm on EC2 instances. The template creates the necessary cloud infrastructure and configures the EC2 instances to form a Docker Swarm, enabling distributed container deployment and basic container orchestration.

## Features

- Spins up vanilla EC2 instances.
- Configures the necessary cloud infrastructure underneath including VPCs and security groups.
- Sets up Docker Swarm on the EC2 instances for distributed container deployment.

## Future Improvements

- Automate the addition of each Swarm node IP to an AWS discovery pool.
- Create an API Gateway resource via the Terraform template that points to the discovery pool. This will allow the API Gateway to load balance among the Swarm nodes without us having to manually update the config each time a new EC2 instance is spun up.

## Usage

```bash
terraform apply
```

## Contributing

Please replace this with instructions on how to contribute to your project.