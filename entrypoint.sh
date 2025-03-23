#!/bin/sh

cd /project
echo "Running '$*'"
eval $*

case "$*" in
  *"dbt-bigquery:docs-generate"*)
    echo "Copying dbt docs to /github/workspace/dbt-docs..."
    mkdir -p /github/workspace/dbt-docs
    cp -r .meltano/transformers/dbt/target/* /github/workspace/dbt-docs/ || echo "Nothing to copy"
    ;;
esac
