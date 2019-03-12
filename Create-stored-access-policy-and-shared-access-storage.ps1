# Define global variables for the script  
$locationName = 'North Europe'  # the data center region you will use  
$storageAccountName= 'tmrprdsa' # the storage account name you will create or use  
$containerName= 'sqlbackup'  # the storage container name to which you will attach the SAS policy with its SAS token  
$policyName = 'tmrpolicy' # the name of the SAS policy 

# Set a variable for the name of the resource group you will create or use  
$resourceGroupName = "tmr-prd-rg"  

# Create a new resource group - comment out this line to use an existing resource group  
New-AzureRmResourceGroup -Name $resourceGroupName -Location $locationName


# Create a new Azure Resource Manager storage account - comment out this line to use an existing Azure Resource Manager storage account  
New-AzureRmStorageAccount -Name $storageAccountName -ResourceGroupName $resourceGroupName -Type Standard_RAGRS -Location $locationName   

# Get the access keys for the Azure Resource Manager storage account  
$accountKeys = Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName  

# Create a new storage account context using an Azure Resource Manager storage account  
$storageContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $accountKeys[0].Value

# Creates a new container in blob storage  
$container = New-AzureStorageContainer -Context $storageContext -Name $containerName  

# Sets up a Stored Access Policy and a Shared Access Signature for the new container  
$policy = New-AzureStorageContainerStoredAccessPolicy -Container $containerName -Policy $policyName -Context $storageContext -StartTime $(Get-Date).ToUniversalTime().AddMinutes(-5) -ExpiryTime $(Get-Date).ToUniversalTime().AddYears(10) -Permission rwld

# Gets the Shared Access Signature for the policy  
$sas = New-AzureStorageContainerSASToken -name $containerName -Policy $policyName -Context $storageContext
Write-Host 'Shared Access Signature= '$($sas.Substring(1))''  

# Sets the variables for the new container you just created
$container = Get-AzureStorageContainer -Context $storageContext -Name $containerName
$cbc = $container.CloudBlobContainer 

# Outputs the Transact SQL to the clipboard and to the screen to create the credential using the Shared Access Signature  
Write-Host 'Credential T-SQL'  
$tSql = "CREATE CREDENTIAL [{0}] WITH IDENTITY='Shared Access Signature', SECRET='{1}'" -f $cbc.Uri,$sas.Substring(1)   
$tSql | clip  
Write-Host $tSql 

# Once you're done with the tutorial, remove the resource group to clean up the resources. 
# Remove-AzureRmResourceGroup -Name $resourceGroupName  