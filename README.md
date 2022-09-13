# AlwaysAI assignemnt task ![Tests](https://github.com/alexbigkid/aai_job/actions/workflows/pipeline.yml/badge.svg)
AlwaysAI job assignment task


## Directory structure
| Directory name | description               |
| :------------- | :------------------------ |
| docs           | documents for the project |
| lambdas        | project lambdas directory |
| terraform      | terraform modules         |


## Deployement strategy
deploy.sh is very flexible it will run all scripts which begin with 3 digits in order,
to make sure the needed infrastructure is available before deploying lamdas

| Script name            | description                                              |
| :--------------------- | :------------------------------------------------------- |
| deploy.sh              | the main script, which is the entry point of deployement |
| 001_DeployTerraform.sh | deployes terraform infrastructure                        |
| 002_DeployLambdas.sh   | deploys all lambdas                                      |
| CommonLib.sh           | common functionality                                     |
