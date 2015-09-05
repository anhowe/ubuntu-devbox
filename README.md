This is an Azure template to create an ubuntu desktop machine

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fanhowe%2Fubuntu-devbox%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Once your vm has been created you will be able to VNC to the machine.

Below are the parameters that the template expects:

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Name for the Storage Account where the Virtual Machine's disks will be placed.If the storage account does not aleady exist in this Resource Group it will be created. |
| adminPassword  | Password for the Virtual Machine  |
| dnsNameForPublicIP  | Unique DNS Name for the Public IP used to access the master Virtual Machine. |
| vmsize | specify an azure vm size for the machine |
