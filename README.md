<div id="top"></div>


<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a></li>
    <li><a href="#prerequisites">Prerequisites</a></li>
    <li><a href="#installation">Installation</a></li>
    <li><a href="#How The Script Works">How The Script Works</a></li>
    <li><a href="#How To Use The Script">How To Use The Script</a></li>
    <li><a href="#Medium Articles">Medium Articles</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

In this project we deploy the `App layer` of <a href="https://github.com/ashwinbittu/terraform-aws-ec2-contino">Conitno Sample Application</a> on an existing VPC in ap-southeast-2 region. As part of this the following AWS resources are created:

* The script uses existing Terraform Module <a href="https://github.com/ashwinbittu/terraform-aws-ec2-contino">`ec2`</a>  to provision 3 `t3.micro` EC2 instances in the following Availability Zones and Subnets.

    |    Subnet    | Availability Zone |
    |--------------|-------------------|
    | subnet-az-2a |  ap-southeast-2a  |
    | subnet-az-2b |  ap-southeast-2b  |
    | subnet-az-2c |  ap-southeast-2c  |

* The script also uses existing Terraform Module <a href="https://github.com/ashwinbittu/terraform-aws-key-pair-contino">`key-pair`</a> to provision a Key pair as well.

<br>

Following are the input parameters while running the script:

- Instance Type: `t3.micro`
- Tags: Add a `Name` tag that is unique for each instance.

Following are the output values after running the script:

1. List of three 3 EC2 Instance IDs and its Names
2. Map value of the Key Name, its Private and Public Keys.

<p align="right">(<a href="#top">back to top</a>)</p>



### Prerequisites

* You already have an AWS free tier account with Admin access.
* You already have a Terraform Cloud free tier account. Please follow this link to find out how: 
* You already created an API Token from the Users section Terraform Cloud free tier account. Please follow this link to find out how: 
* You already have/Created Personalized Access Token to access the following GitHub repos through script:
    * <a href="https://github.com/ashwinbittu/terraform-aws-ec2-contino">`ec2`</a>
    * <a href="https://github.com/ashwinbittu/terraform-aws-key-pair-contino">`key-pair`</a>
    * <a href="https://github.com/ashwinbittu/terraform-aws-ec2-contino">`Conitno Sample Application`</a>
    * <a href="https://github.com/ashwinbittu/managecontinoinfra">`ManageInfra`</a>

    Please follow this link to find out how to create Personalized Access Token in GitHub.

* You already have have AWS_ACCESS_KEY_ID & AWS_SECRET_ACCESS_KEY pair which can be used to access the AWS ENV through any CLI. Please follow this link to find out how: 


### Installation

1. Get a t2.micro Amazon Linux EC2 Instance. This is for Running the script.
2. Install jq : sudo yum install jq -y
3. Install git : sudo yum install jq -y
4. Clone the repo
   ```sh
   git clone https://github.com/ashwinbittu/managecontinoinfra.git
      ```
3. Give appropriate permission to the file manageinfra.sh for executing it.
4. Open the file manageinfra.sh & update the following entries with the values already mentioned in the Prerequisites section.
    * TFE_TOKEN="<TFE_TOKEN>" 
    * TFE_ORG="<TFE-ORG>"
    * TFE_ADDR="app.terraform.io"
    * execdir="<SCRIPT-EXEC-DIR>"
    * REPO_API_TOKEN="<GITHUB_Personal Access Token>" 
    * REPO_FID="<GITHUB_USER_ID>"
    * AWS_ACCESS_KEY_ID="<AWS_ACCESS_KEY_ID>"
    * AWS_SECRET_ACCESS_KEY="<AWS_SECRET_ACCESS_KEY>"
5. 
Install NPM packages
   ```sh
   npm install
   ```
4. Enter your API in `config.js`
   ```js
   const API_KEY = 'ENTER YOUR API';
   ```

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- HOW IT WORKS -->
## How The Script Works

<!-- USAGE EXAMPLES -->
## How To Use The Script

Use this space to show useful examples of how a project can be used. Additional screenshots, code examples and demos work well in this space. You may also link to more resources.

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- Medium Articles -->
## Medium Articles

<p align="right">(<a href="#top">back to top</a>)</p>

