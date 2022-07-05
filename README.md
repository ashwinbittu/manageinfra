<div id="top"></div>


<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a></li>
    <li><a href="#prerequisites">Prerequisites</a></li>
    <li><a href="#installation">Installation</a></li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
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
* You already have/Created Personalized Access Tokens for accessing the following GitHub repos through script:
    * <a href="https://github.com/ashwinbittu/terraform-aws-ec2-contino">`ec2`</a>
    * <a href="https://github.com/ashwinbittu/terraform-aws-key-pair-contino">`key-pair`</a>
    * <a href="https://github.com/ashwinbittu/terraform-aws-ec2-contino">Conitno Sample Application</a>
    * <a href="https://github.com/ashwinbittu/managecontinoinfra">Conitno Sample Application</a>

    Please follow this link to find out how to create Personalized Access Tokens in GitHub.

* You already have have a AWS_ACCESS_KEY_ID & AWS_SECRET_ACCESS_KEY pair. Please follow this link to find out how: 


### Installation

_Below is an example of how you can instruct your audience on installing and setting up your app. This template doesn't rely on any external dependencies or services._

1. Get a t2.micro Amazon Linux EC2 Instance
2. Install jq : sudo yum install jq -y
3. Install git : sudo yum install jq -y
4. Clone the repo
   ```sh
   git clone https://github.com/ashwinbittu/managecontinoinfra.git
      ```
3. Give execution permission to manageinfra.sh
Install NPM packages
   ```sh
   npm install
   ```
4. Enter your API in `config.js`
   ```js
   const API_KEY = 'ENTER YOUR API';
   ```

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Usage

Use this space to show useful examples of how a project can be used. Additional screenshots, code examples and demos work well in this space. You may also link to more resources.

_For more examples, please refer to the [Documentation](https://example.com)_

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- ROADMAP -->
## Roadmap

- [x] Add Changelog
- [x] Add back to top links
- [ ] Add Additional Templates w/ Examples
- [ ] Add "components" document to easily copy & paste sections of the readme
- [ ] Multi-language Support
    - [ ] Chinese
    - [ ] Spanish

See the [open issues](https://github.com/othneildrew/Best-README-Template/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Your Name - [@your_twitter](https://twitter.com/your_username) - email@example.com

Project Link: [https://github.com/your_username/repo_name](https://github.com/your_username/repo_name)

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

Use this space to list resources you find helpful and would like to give credit to. I've included a few of my favorites to kick things off!

* [Choose an Open Source License](https://choosealicense.com)
* [GitHub Emoji Cheat Sheet](https://www.webpagefx.com/tools/emoji-cheat-sheet)
* [Malven's Flexbox Cheatsheet](https://flexbox.malven.co/)
* [Malven's Grid Cheatsheet](https://grid.malven.co/)
* [Img Shields](https://shields.io)
* [GitHub Pages](https://pages.github.com)
* [Font Awesome](https://fontawesome.com)
* [React Icons](https://react-icons.github.io/react-icons/search)

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/othneildrew/Best-README-Template.svg?style=for-the-badge
[contributors-url]: https://github.com/othneildrew/Best-README-Template/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/othneildrew/Best-README-Template.svg?style=for-the-badge
[forks-url]: https://github.com/othneildrew/Best-README-Template/network/members
[stars-shield]: https://img.shields.io/github/stars/othneildrew/Best-README-Template.svg?style=for-the-badge
[stars-url]: https://github.com/othneildrew/Best-README-Template/stargazers
[issues-shield]: https://img.shields.io/github/issues/othneildrew/Best-README-Template.svg?style=for-the-badge
[issues-url]: https://github.com/othneildrew/Best-README-Template/issues
[license-shield]: https://img.shields.io/github/license/othneildrew/Best-README-Template.svg?style=for-the-badge
[license-url]: https://github.com/othneildrew/Best-README-Template/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/othneildrew
[product-screenshot]: images/screenshot.png
