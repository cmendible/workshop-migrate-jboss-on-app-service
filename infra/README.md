## Using MTA to analyze the  application

Run the following commands to analyze the application using MTA:

```bash
podman login registry.redhat.io
./mta-cli analyze -i ./ -o ./mta_report -s weblogic -t eap7 --overwrite
```

> Note: The `podman login` command is required to authenticate with the Red Hat registry.

Build the application using the following command:

```bash
mvn clean package
```

## Running the application locally

To run the application locally, use the following command:

```bash
$JBOSS_HOME/bin/standalone.sh -b 0.0.0.0
```

To check tthe local database deployment, use the following command:

```bash
PGPASSWORD=coolstore123 psql -h database -U coolstore monolith -c 'select itemid, quantity from INVENTORY;'
```

## Deploying the application to Azure App Service

To deploy the required resources to Azure, use the following commands:

```bash
cd infra
terraform init
terraform apply
```

To deploy the application to Azure App Service, use the following commands:

```bash
$RESOURCE_GROUP=$(terraform output -raw resource_group_name)
$WEBAPP_NAME=$(terraform output -raw app_service_name)

cd ..

az webapp deploy --resource-group $RESOURCE_GROUP --name $WEBAPP_NAME --src-path .devcontainer/setup/jboss-cli-commands-appservice.cli --target-path /home/site/libs/jboss-cli-commands-appservice.cli --type lib --restart false

az webapp deploy --resource-group $RESOURCE_GROUP --name $WEBAPP_NAME --src-path ./target/ROOT.war --type war --restart false

az webapp deploy --resource-group $RESOURCE_GROUP --name $WEBAPP_NAME --src-path .devcontainer/setup/startup.sh --type startup --restart true
```

> Note: The `jboss-cli-commands-appservice.cli` file is used to configure the application server, adding the required data sources and drivers.

## Reading the application logs

To read the application logs, use the following command:

```bash
az webapp log tail --resource-group $RESOURCE_GROUP --name $WEBAPP_NAME
```

## Connecting to the JBOSS EAP7 application server

In the Azure portal, navigate to the App Service and click on the "SSH" option to connect to the App Service Instance.

Once connected, use the following commands to connect to the JBOSS EAP7 application server and read the data sources configuration

```bash
$JBOSS_HOME/bin/jboss-cli.sh --connect

/subsystem=datasources:read-resource
```
