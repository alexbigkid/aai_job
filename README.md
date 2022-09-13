# AlwaysAI assignemnt task ![Tests](https://github.com/alexbigkid/aai_job/actions/workflows/pipeline.yml/badge.svg)
AlwaysAI job assignment task


## Deployement strategy
deploy.sh is very flexible it will run all scripts which begin with 3 digits in order,
to make sure the needed infrastructure is available before deploying lambdas

| Script name            | description                                              |
| :--------------------- | :------------------------------------------------------- |
| Deploy.sh              | the main script, which is the entry point of deployement |
| CommonLib.sh           | common functionality                                     |
| InstallTools.sh        | Installs any other needed tools                          |
| 001_DeployTerraform.sh | deployes terraform infrastructure                        |
| 002_DeployLambdas.sh   | deploys all lambdas                                      |


## Directory structure
| Directory name    | description                    |
| :---------------- | :----------------------------- |
| docs              | documents for the project      |
| integration-tests | location for integration tests |
| lambdas           | project lambdas directory      |
| terraform         | terraform modules              |
