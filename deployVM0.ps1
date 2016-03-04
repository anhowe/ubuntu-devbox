$VerbosePreference="Continue"
$deployName="anhowe0304a"
$RGName=$deployName
$locName="West US"
$templateFile= "azuredeploy.json"
$templateParameterFile= "azuredeploy.parameters.json"
New-AzureRmResourceGroup -Name $RGName -Location $locName -Force
New-AzureRmResourceGroupDeployment -Name $deployName -ResourceGroupName $RGName -TemplateParameterFile $templateParameterFile -TemplateFile $templateFile
