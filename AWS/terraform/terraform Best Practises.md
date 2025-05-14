### 📁 **Directory Structure Example**

terraform-project/
├── main.tf
├── variables.tf
├── outputs.tf
├── provider.tf
├── backendv
├── locals.tf
├── data.tf
├── terraform.tf
├── modules/
│   └── ec2-instance/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── scripts/
|   └── setup.sh

#### 1. **`main.tf`**

* **Purpose** : Define core infrastructure resources and modules.
* **Contains** :
  * `resource` blocks (e.g., `aws_instance`, `aws_s3_bucket`)
  * `module` blocks to include reusable modules
  * `provider` configuration (if not separated)
* **Example** :
  ```
  resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  }

#### 2. **`variables.tf`**

* **Purpose** : Declare input variables for your configuration.
* **Contains** :
  * `variable` blocks with type definitions, descriptions, and default values
* **Example** :
  ```
  variable "ami_id" {
    description = "AMI ID for the EC2 instance"
    type        = string
  }

#### 3. **`outputs.tf`**

* **Purpose** : Define outputs to expose information about your infrastructure.
* **Contains** :
  * `output` blocks referencing resource attributes
* **Example** :
  ```
  output "instance_ip" {
    description = "Public IP of the EC2 instance"
    value       = aws_instance.web.public_ip
  }

#### 4. **`provider.tf`**

* **Purpose** : Configure the Terraform provider(s).
* **Contains** :
  * `provider` blocks specifying credentials and regions
  * `terraform` block with required provider versions
* **Example** :
  ```
  terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 4.0"
      }
    }
  }

  provider "aws" {
    region = var.aws_region
  }

#### 5. **`backend.tf`**

* **Purpose** : Configure remote state storage.
* **Contains** :
  * `terraform` block with `backend` configuration
* **Example** :
  ```
  terraform {
    backend "s3" {
      bucket = "my-terraform-state"
      key    = "path/to/my/key"
      region = "us-west-2"
    }
  }

#### 6. **`locals.tf`**

* **Purpose** : Define local variables for reuse within the configuration.
* **Contains** :
  * `locals` block with computed values
* **Example** :
  ```
  locals {
    instance_name = "${var.environment}-web-server"
  }

#### 7. **`data.tf`**

* **Purpose** : Define data sources to fetch information from providers.
* **Contains** :
  * `data` blocks referencing existing resources
* **Example** :
  ```
  data "aws_ami" "latest" {
    most_recent = true
    owners      = ["self"]
    filter {
      name   = "name"
      values = ["my-ami-*"]
    }
  }

#### 8. **`outputs.tf`**

* **Purpose** : Define outputs to expose information about your infrastructure.
* **Contains** :
  * `output` blocks referencing resource attributes
* **Example** :
  ```
  output "instance_ip" {
    description = "Public IP of the EC2 instance"
    value       = aws_instance.web.public_ip
  }

#### 9. **`terraform.tfvars`**

* **Purpose** : Assign values to input variables.
* **Contains** :
  * Variable assignments matching those declared in `variables.tf`
* **Example** :
  ```
  ami_id        = "ami-0abcdef1234567890"
  instance_type = "t2.micro"
  aws_region    = "us-west-2"
  </span></code></div></div></pre>


---
