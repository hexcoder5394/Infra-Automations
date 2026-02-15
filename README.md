# Azure 3-Tier Architecture with Terraform

![Terraform](https://img.shields.io/badge/Terraform-1.0+-purple?style=flat-square&logo=terraform)
![Azure](https://img.shields.io/badge/Provider-Azure-blue?style=flat-square&logo=microsoft-azure)
![Status](https://img.shields.io/badge/Status-Active-success?style=flat-square)

## 📖 Project Overview
This project automates the deployment of a secure, "Enterprise-Grade" 3-Tier infrastructure on Microsoft Azure using Terraform. 

It mimics a real-world corporate environment where resources are segmented by responsibility (Web, App, Data) and isolated using strict networking rules. The goal was to move beyond simple resource creation and focus on **Network Security**, **Dependency Mapping**, and **Infrastructure as Code (IaC)** best practices.

## 🏗️ Architecture
The infrastructure is designed with a "Defense in Depth" approach:

![Architecture Diagram](./architecture-diagram.png)
<img width="597" height="327" alt="image" src="https://github.com/user-attachments/assets/19b7f9f1-9da9-4f2a-ad68-9a85e2050231" />


### The Three Tiers
1.  **Web Tier (Public):**
    * Contains the Load Balancer and Linux VMs.
    * Exposed to the internet via HTTP (Port 80) only.
2.  **App Tier (Private):**
    * Contains the application logic (Simulated).
    * **Security:** Only accepts traffic from the Web Tier. No direct Internet access.
3.  **Data Tier (Isolated):**
    * Contains an Azure SQL Database.
    * **Security:** Uses a **Private Endpoint** to ensure traffic never traverses the public internet.

## 🚀 Key Features
* **Highly Available Networking:** A custom VNet (`10.0.0.0/16`) segmented into three distinct subnets with calculated CIDR blocks.
* **Granular Security:** * **NSGs (Network Security Groups)** are applied at the subnet level to enforce traffic flow rules.
    * **Private Link** implementation for the database, eliminating public IP exposure.
* **Load Balancing:** A Layer-4 Load Balancer distributes traffic to the backend pool, complete with Health Probes and Load Balancing Rules.
* **Dynamic Configuration:** Uses `variables.tf` to allow for easy switching between environments (e.g., `dev` vs `prod`).

## 🛠️ Prerequisites
* [Terraform](https://www.terraform.io/downloads) (v1.0+)
* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
* An active Azure Subscription

## 💻 Getting Started

### 1. Clone the Repository
```bash
git clone [https://github.com/hexcoder5394/Infra-Automations.git)
cd azure-3tier-terraform
