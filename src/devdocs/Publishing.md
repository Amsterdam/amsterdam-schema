# Publishing

Publishing the schemas to the Azure Blob Storage is handled by the publish-schemas pipeline. This calls the `publish` cli command under the hood.

In order to publish the Amsterdam Schema from your local environment to the dev
storage, you will need to do an install and set some environment variables.

Install the Python package included in this repository:

```console
% python3.8 -m venv venv
% pip install -U pip setuptools
% pip install '.[tests,dev]'
```

The extra options `tests` and `dev` are not strictly necessary for publishing,
but are handy to have installed while working on the schema definitions.

You will also need to set some environment variables.

```console
export SCHEMAS_SA_NAME=[dev|test]schemassa
export SCHEMAS_SA_KEY=$(az storage account keys list \
    --account-name $SCHEMAS_SA_NAME | jq -r \
    '.[] | select(.keyName == "key1") | .value');
```

Once everything has been set up, you can publish with:

```console
% publish
```

This uploads everything to the environment of your choosing and also creates
the index files needed for other processes.

Note that these environments are ephemeral, meaning that once a branch is merged
into master, the pipelines start again and everything will be replaced.
