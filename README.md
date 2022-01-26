# PostDeploymentSecurityCheck-Study

[![Deploy app to Heroku](https://github.com/ExcelliumSA/PostDeploymentSecurityCheck-Study/actions/workflows/deployment.yml/badge.svg?branch=main)](https://github.com/ExcelliumSA/PostDeploymentSecurityCheck-Study/actions/workflows/deployment.yml)

Contains the materials used for the blog post about possible validation after a web app deployment.

# Status

Work in progress...

# Blog post link

TODO

# Lab

> The NodeJS sample app is deployed, at each commit on the **main** branch, on a [Heroku](https://www.heroku.com/) platform instance located on https://xlm-blogpost-deploy-check.herokuapp.com

The folder **app** contain the NodeJS sample application against all post-deployment validation are applied.

Use the command below to start the app - it will be accessible on http://localhost:5000 :

```bash
$ cd app
# npm install
$ npm start
Listening on 5000
...
```

# Other folders and files

* Folder **[docs](docs)**: Contain an example of HTML report (generated using [aha](http://manpages.ubuntu.com/manpages/bionic/man1/aha.1.html) tools) of the validations for the sample application.
* Folder **[post](post)**: Contain pictures used for the blog post.
* File **[validate.sh](validate.sh)**: Shell script of a POC containing all post deployment security validations proposed in the blog post. It is executed by this [workflow](.github/workflows/deployment.yml).
* File **[recipe.yml](recipe.yml)**: *[venom](https://github.com/ovh/venom)* test plan to demonstrate a migration from a shell script to a descriptive test plan of the shell script above.
* File **[content_excluded_from_deployment.txt](content_excluded_from_deployment.txt)**: Dictionary of file not expected to be present on the deployed application and used by *[validate.sh](validate.sh)* shell script.

# References

* https://github.com/ovh/venom/issues/494

