$allRGs = (Get-AzureRmResourceGroup).ResourceGroupName
Write-Warning "Found $($allRGs | measure | Select -ExpandProperty Count) total RGs"

$aliasedRGs = (Find-AzureRmResourceGroup -Tag @{ "CREATED-BY" = $null }).Name
Write-Warning "Found $($aliasedRGs | measure | Select -ExpandProperty Count) aliased RGs"
  
$notAliasedRGs = $allRGs | ?{-not ($aliasedRGs -contains $_)}
Write-Warning "Found $($notAliasedRGs | measure | Select -ExpandProperty Count) un-tagged RGs"

foreach ($rg in $notAliasedRGs)
{
    $currentTime = Get-Date

    $endTime = $currentTime.AddDays(-89 * $cnt)
    $startTime = $endTime.AddDays(-89)
        
    $callers = Get-AzureRmLog -ResourceGroup $rg -StartTime $startTime -EndTime $endTime -WarningAction SilentlyContinue |
        Where {$_.Authorization.Action -eq "Microsoft.Resources/deployments/write" -or $_.Authorization.Action -eq "Microsoft.Resources/subscriptions/resourcegroups/write" } | 
        Select -ExpandProperty Caller | 
        Group-Object | 
        Sort-Object  | 
        Select -ExpandProperty Name

    if ($callers)
    {
        $owner = $callers | Select-Object -First 1
        $alias = $owner -replace "@microsoft.com",""
            
        $tags = (Get-AzureRmResourceGroup -Name $rg).Tags
        $tags += @{ "CREATED-BY"=$alias }

        $rg + ", " + $alias
        if (-not $dryRun) 
        {
            Set-AzureRmResourceGroup -Name $rg -Tag $tags
        }
    } 
    else 
    {
        $rg + ", Unknown"
    }   
}