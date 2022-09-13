#!/bin/bash

# e: stop if any errors
# u: Treat unset variables and parameters as an error
# set -eu

EXPECTED_NUMBER_OF_PARAMETERS=0
COMMON_LIB_FILE="./CommonLib.sh"
LAMBDA_DIR=""
LAMBDAS_DIR_SUFFIX="lambdas"
LAMBDA_STRING="Lambda"

PrintUsageAndExitWithCode()
{
    echo
    echo "$0 will deploy Lambdas to AWS environment."
    echo "This script ($0) must be called with $EXPECTED_NUMBER_OF_PARAMETERS parameters."
    echo "  The REGION environment variable needs to be set to: us-east-1, us-east-2, us-west-1 us-west-2"
    echo "  The AWS_ACCESS_KEY_ID environment variable needs to be setup"
    echo "  The AWS_SECRET_ACCESS_KEY environment variable needs to be setup"
    echo
    echo "  $0 --help           - display this info"
    echo "EXIT_CODE = $1"
    exit $1
}
export -f PrintUsageAndExitWithCode

DeployLambdaProject()
{
    echo
    echo "-> ${FUNCNAME[0]} ($@)"
    local LOCAL_EXIT_CODE=$TRUE
    local LOCAL_REGION=$1
    local LOCAL_LAMBDA_PRJ=$2
    local LOCAL_LAMBDA_DIRECTORY=$3
    local AWS_PROFILE="default"

    pushd $LOCAL_LAMBDA_PRJ/$LOCAL_LAMBDA_DIRECTORY
    if [[ $LOCAL_EXIT_CODE -eq $TRUE ]]; then
        echo "**** deploying: $LOCAL_LAMBDA_PRJ/$LOCAL_LAMBDA_DIRECTORY"
        echo "serverless --region $LOCAL_REGION --stackName $LOCAL_LAMBDA_DIRECTORY deploy"
        serverless --region $LOCAL_REGION --stackName $LOCAL_LAMBDA_DIRECTORY deploy

        LOCAL_EXIT_CODE=$?
    fi
    popd

    echo "<- ${FUNCNAME[0]} ($LOCAL_LAMBDA_PRJ $LOCAL_EXIT_CODE)"
    echo
    return $LOCAL_EXIT_CODE
}
export -f DeployLambdaProject

TestLambdaProject()
{
    echo
    echo "-> ${FUNCNAME[0]} ($@)"
    local LOCAL_EXIT_CODE=$TRUE
    local LOCAL_RET_VALUE=$TRUE
    local LOCAL_LAMBDA_PRJ=$1
    local LOCAL_LAMBDA_TEST_DIR=$2
    local LOCAL_PROJECT_ROOT_DIR=$PWD

    pushd $LOCAL_LAMBDA_PRJ/$LOCAL_LAMBDA_TEST_DIR

    # CS_PROJECT=$(ls *.csproj)
    # echo "testing in: $LOCAL_LAMBDA_PRJ/$LOCAL_LAMBDA_TEST_DIR project: $CS_PROJECT"

    popd

    echo "<- ${FUNCNAME[0]} ($LOCAL_LAMBDA_PRJ $LOCAL_EXIT_CODE)"
    echo
    return $LOCAL_EXIT_CODE
}
export -f TestLambdaProject

TestAndDeployLambda()
{
    local LCL_YELLOW='\033[1;33m'
    local LCL_NC='\033[0m' # No Color
    echo
    echo -e "${LCL_YELLOW}-> ${FUNCNAME[0]} ($@)${LCL_NC}"
    local LOCAL_REGION=$1
    local LOCAL_LAMBDA_PRJ=$2
    local LOCAL_EXIT_CODE=$TRUE
    local LOCAL_RET_VALUE=$TRUE
    local LOCAL_TRUNCATED_LAMBDA_DIRECTORY=${LOCAL_LAMBDA_PRJ%%Lambda}

    echo
    echo "**** About to test, build and deploy lambda $LOCAL_TRUNCATED_LAMBDA_DIRECTORY"
    echo "-----------------------------------------------------------------"
    TestLambdaProject $LOCAL_LAMBDA_PRJ $LOCAL_TRUNCATED_LAMBDA_DIRECTORY.Tests
    LOCAL_RET_VALUE=$?
    [[ $LOCAL_EXIT_CODE -eq $TRUE ]] && LOCAL_EXIT_CODE=$LOCAL_RET_VALUE
    DeployLambdaProject $LOCAL_REGION $LOCAL_LAMBDA_PRJ $LOCAL_TRUNCATED_LAMBDA_DIRECTORY
    LOCAL_RET_VALUE=$?
    [[ $LOCAL_EXIT_CODE -eq $TRUE ]] && LOCAL_EXIT_CODE=$LOCAL_RET_VALUE

    echo -e "${LCL_YELLOW}<- ${FUNCNAME[0]} ($LOCAL_LAMBDA_PRJ $LOCAL_EXIT_CODE)${LCL_NC}"
    echo
    return $LOCAL_EXIT_CODE
}
export -f TestAndDeployLambda



# -----------------------------------------------------------------------------
# main
# -----------------------------------------------------------------------------
# include common library, fail if does not exist
if [[ -f $COMMON_LIB_FILE ]]; then
    source $COMMON_LIB_FILE
else
    echo "ERROR: $COMMON_LIB_FILE does not exist in the local directory."
    echo "  $COMMON_LIB_FILE contains common definitions and functions"
    exit 1
fi

echo
echo -e "${GREEN}-> $0 ($@)${NC}"


IsParameterHelp $# $1 && PrintUsageAndExitWithCode $EXIT_CODE_SUCCESS
CheckNumberOfParameters $EXPECTED_NUMBER_OF_PARAMETERS $@ || PrintUsageAndExitWithCode $?

[ "$REGION" == "" ] && echo -e "${RED}ERROR:${NC} ${PURPLE}REGION is not defined${NC}" && PrintUsageAndExitWithCode $EXIT_CODE_GENERAL_ERROR
[ "$AWS_ACCESS_KEY_ID" == "" ] && echo -e "${RED}ERROR:${NC} ${PURPLE}AWS_ACCESS_KEY_ID is not defined${NC}" && PrintUsageAndExitWithCode $EXIT_CODE_GENERAL_ERROR
[ "$AWS_SECRET_ACCESS_KEY" == "" ] && echo -e "${RED}ERROR:${NC} ${PURPLE}AWS_SECRET_ACCESS_KEY is not defined${NC}" && PrintUsageAndExitWithCode $EXIT_CODE_GENERAL_ERROR

GetFullDirectoryNameFor $LAMBDAS_DIR_SUFFIX LAMBDA_DIR || PrintUsageAndExitWithCode $?
echo "  [$0]: LAMBDA_DIR    = $LAMBDA_DIR"
echo "  [$0]: REGION        = $REGION"

# validate env and region
IsPredefinedParameterValid $ENV "${ENV_ARRAY[@]}" || PrintUsageAndExitWithCode $EXIT_CODE_NOT_VALID_PARAMETER
IsPredefinedParameterValid $REGION "${REGION_ARRAY[@]}" || PrintUsageAndExitWithCode $EXIT_CODE_NOT_VALID_PARAMETER

pushd $LAMBDA_DIR

ALL_LAMBDA_DIRECTORIES=$(ls -d *$LAMBDA_STRING)
echo "ALL_LAMBDA_DIRECTORIES = "
echo "$ALL_LAMBDA_DIRECTORIES"

parallel --halt now,fail=1 TestAndDeployLambda $REGION ::: ${ALL_LAMBDA_DIRECTORIES[@]}
RET_VALUE=$?
[[ $EXIT_CODE -eq $TRUE ]] && EXIT_CODE=$RET_VALUE

popd
RET_VALUE=$?
[[ $EXIT_CODE -eq $TRUE ]] && EXIT_CODE=$RET_VALUE

echo -e "${GREEN}<- $0 ($EXIT_CODE)${NC}"
echo
exit $EXIT_CODE
