# Use the official Terraform image from HashiCorp
FROM hashicorp/terraform:latest

# Set the working directory in the container
WORKDIR /workspace

# Copy your Terraform configuration files into the container
COPY main.tf .

# Initialize Terraform and apply the configuration
ENTRYPOINT ["terraform"]

# Default command to run Terraform commands (e.g., `terraform init`)
CMD ["init"]
