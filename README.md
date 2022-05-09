# PostDeploymentSecurityCheck-Study

Contains the materials used for the blog post about possible validation after a web app deployment.

# Blog post link

https://excellium-services.com/2022/05/09/continuous-deployment-applying-security-for-web-application-development/

# Lab

The folder **app** contain the NodeJS sample application against all post-deployment validation are applied.

Use the command below to start the app - it will be accessible on http://localhost:5000 :

```bash
$ cd app
# npm install
$ npm start
Listening on 5000
...
```

# Utility docker image

This [Dockerfile](Dockerfile) provides a dedicated ephemeral docker image that can be used to run presented post deployment security validations (and other ones). The objective is to prevent to overload CI/CD build agent with tools and also prevent tools version conflict.

The folder **/share** inside the image is present to allow data sharing between the container and the host.

Use the following commands to use the image:

```bash
# Build the image
$ docker build -t excellium/toolbox .
# Instanciate a temporary container to run a validation leveraging tools inside the box
$ docker run --rm -v "/host_share_folder:/share" -i -t excellium/toolbox /bin/bash /home/validator/testssl/testssl.sh https://myapp.com
$ docker run --rm -v "/host_share_folder:/share" -i -t excellium/toolbox /home/validator/venom run /share/recipe.yml
# Instanciate a temporary container to have a shell into it
$ docker run --rm -v "/host_share_folder:/share" -i -t excellium/toolbox /bin/bash
```

# Other folders and files

* Folder **[docs](docs)**: Contain an example of HTML report (generated using [aha](http://manpages.ubuntu.com/manpages/bionic/man1/aha.1.html) tools) of the validations for the sample application.
* Folder **[post](post)**: Contain pictures used for the blog post.
* File **[validate.sh](validate.sh)**: Shell script of a POC containing all post deployment security validations proposed in the blog post. It is executed by this [workflow](.github/workflows/deployment.yml).
* File **[recipe.yml](recipe.yml)**: *[venom](https://github.com/ovh/venom)* test plan to demonstrate a migration from a shell script to a descriptive test plan of the shell script above.
* File **[content_excluded_from_deployment.txt](content_excluded_from_deployment.txt)**: Dictionary of file not expected to be present on the deployed application and used by *[validate.sh](validate.sh)* shell script.
* File **[validate_cookie_properties.py](validate_cookie_properties.py)**: Python3 script performing validation on the cookies present in an HTTP response.

# Issue opened in different tools

* https://github.com/ovh/venom/issues/494
* https://github.com/ovh/venom/issues/499
* https://github.com/projectdiscovery/nuclei/issues/1542

