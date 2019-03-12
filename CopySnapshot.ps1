Connect-AzureRMAccount

Set-AzureRmContext -Subscription 1901e14c-9d5c-46bb-a3f0-f83565626174

#Provide the subscription Id of the subscription where snapshot exists
$sourceSubscriptionId='1901e14c-9d5c-46bb-a3f0-f83565626174'

#Provide the name of your resource group where snapshot exists
$sourceResourceGroupName='ond-test-rg'

#Provide the name of the snapshot
$snapshotName='LabVMSnapshot'

#Set the context to the subscription Id where snapshot exists
Select-AzureRMSubscription -SubscriptionId $sourceSubscriptionId

#Get the source snapshot
$snapshot= Get-AzureRMSnapshot -ResourceGroupName $sourceResourceGroupName -Name $snapshotName

#Provide the subscription Id of the subscription where snapshot will be copied to
#If snapshot is copied to the same subscription then you can skip this step
$targetSubscriptionId='1901e14c-9d5c-46bb-a3f0-f83565626174'

#Name of the resource group where snapshot will be copied to
$targetResourceGroupName='ing-test-rg'

#Set the context to the subscription Id where snapshot will be copied to
#If snapshot is copied to the same subscription then you can skip this step
Select-AzureRMSubscription -SubscriptionId $targetSubscriptionId

$snapshotConfig = New-AzureRMSnapshotConfig -SourceResourceId $snapshot.Id -Location $snapshot.Location -CreateOption Copy 

#Create a new snapshot in the target subscription and resource group
New-AzureRMSnapshot -Snapshot $snapshotConfig -SnapshotName $snapshotName -ResourceGroupName $targetResourceGroupName