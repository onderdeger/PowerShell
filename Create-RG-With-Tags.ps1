Login-AzureRmAccount

$subscription = Read-Host -Prompt 'Input Subscription Name'

Set-AzureRmContext -Subscription $subscription

$RG = Read-Host -Prompt 'Input Resource Group Name - (mrpi-mph-dev-rg-01)'
$Location = Read-Host -Prompt 'Input Location'
$Owner = Read-Host -Prompt 'Input Resource Owner Name'
$ProjectName = Read-Host -Prompt 'Input Project Name'
$ProjectVersion = Read-Host -Prompt 'Input Project Version'
$CostCenter = Read-Host -Prompt 'Input Cost Centre Charge Back'
$Environment = Read-Host -Prompt 'Input Environment Name'
$STMail = Read-Host -Prompt 'Input Support Team Email'
$DataC = Read-Host -Prompt 'Input Data Classification'

New-AzureRmResourceGroup -ResourceGroupName $RG -Location $Location -Tag @{Owner=$Owner; ProjectName=$ProjectName; ProjectVersion=$ProjectVersion; CostCenter=$CostCenter; Environment=$Environment; SupportTeamEmail=$STMail; DataClasification = $DataC }