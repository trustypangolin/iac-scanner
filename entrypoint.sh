#!/bin/sh

if [ -z "$scanfolder" ]; then
  echo "Environment variable scanfolder is not set. Quitting."
  exit 1
fi

if [ ! -d "$scanfolder" ]; then
  echo "${scanfolder} path not found. Quitting."
  exit 1
fi

if [ -z "$INPUT_SCANNER" ]; then
  echo "environment variable SCANNER is not set. Please use 'cfn-lint', 'cfn-nag', 'checkov', or 'all' Quitting."
  exit 1
fi

case $INPUT_SCANNER in

  "cfn-lint")
    echo -n "scanning with only cfn-lint"
    sh -c "find ${scanfolder} -type d \( -path .git -o -path ./.github \) -prune -o -type f \( ${CFN_LINT_FIND} \) -print -exec cfn-lint ${CFN_LINT_OPT} {} + "
    ;;

  "cfn-guard")
    echo -n "...scanning with only cfn-nag"
    sh -c "cfn-guard ${CFN_GUARD_OPT} ${scanfolder}"
    ;;

  "cfn-nag")
    echo -n "...scanning with only cfn-nag"
    sh -c "cfn_nag_scan ${CFN_NAG_OPT} --input-path ${scanfolder}"
    ;;

  "checkov")
    echo -n "...scanning with only checkov"
    sh -c "checkov ${CHECKOV_OPT} -d ${scanfolder}"
    ;;

  "all")
    echo -n "...scanning with all tools"
    sh -c "find ${scanfolder} -type d \( -path .git -o -path ./.github \) -prune -o -type f \( ${CFN_LINT_FIND} \) -print -exec cfn-lint ${CFN_LINT_OPT} {} + "
    sh -c "cfn_nag_scan ${CFN_NAG_OPT} --input-path ${scanfolder}"
    sh -c "checkov ${CHECKOV_OPT} -d ${scanfolder}"
    ;;

  *)
    echo -n "Environment variable SCANNER is not set allowed option. Please use 'cfn-lint', 'cfn-nag', 'checkov', or 'all' Quitting."
    exit 1
    ;;
esac
