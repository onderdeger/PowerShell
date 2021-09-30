
Connect-AzAccount -Tenant '7eaabc33-8728-4f89-bc27-f023795e938a' -SubscriptionId 'fe688881-14d5-4b7a-985a-10dbcaaf3097'

##### Create Shared Data Disks from snaphots ####
#### Change Resource Group Name, VM names, SnapShot Names, Disk Names and location #####

$ResourceGroup = "Lab2"
$vmName1 = "LabVM01"
$vmName2 = "LabVM02"
$vmName3 = "LabVM03"

$location = "northeurope"
$snapshotName1 = "LAbVM01_DataDisk_0_snapshot_300921"
$snapshotName2 = "LAbVM01_DataDisk_1_snapshot_300921"
$snapshotName3 = "LAbVM01_DataDisk_2_snapshot_300921"
$snapshotName4 = "LAbVM01_DataDisk_3_snapshot_300921"
$snapshotName5 = "LAbVM01_DataDisk_4_snapshot_300921"
$snapshotName6 = "LAbVM01_DataDisk_5_snapshot_300921"
$snapshotName7 = "LAbVM01_DataDisk_6_snapshot_300921"
$snapshotName8 = "LAbVM01_DataDisk_7_snapshot_300921"
$snapshotName9 = "LAbVM01_DataDisk_8_snapshot_300921"



$DiskName1 = "SharedDataDisk_10"
$DiskName2 = "SharedDataDisk_20"
$DiskName3 = "SharedDataDisk_3"
$DiskName4 = "SharedDataDisk_4"
$DiskName5 = "SharedDataDisk_5"
$DiskName6 = "SharedDataDisk_6"
$DiskName7 = "SharedDataDisk_7"
$DiskName8 = "SharedDataDisk_8"
$DiskName9 = "SharedDataDisk_9"
 
$snapshotinfo1 = Get-AzSnapshot -ResourceGroupName $ResourceGroup -SnapshotName $snapshotName1
$diskConfig1 = New-AzDiskConfig -SkuName Premium_LRS -Location $location -CreateOption Copy -SourceResourceId $snapshotinfo1.Id -MaxSharesCount 3
$newDisk1 = New-AzDisk -DiskName $DiskName1 -Disk $diskConfig1 -ResourceGroupName $ResourceGroup

$snapshotinfo2 = Get-AzSnapshot -ResourceGroupName $ResourceGroup -SnapshotName $snapshotName2
$diskConfig2 = New-AzDiskConfig -SkuName Premium_LRS -Location $location -CreateOption Copy -SourceResourceId $snapshotinfo2.Id -MaxSharesCount 3
$newDisk2 = New-AzDisk -DiskName $DiskName2 -Disk $diskConfig2 -ResourceGroupName $ResourceGroup

$snapshotinfo3 = Get-AzSnapshot -ResourceGroupName $ResourceGroup -SnapshotName $snapshotName3
$diskConfig3 = New-AzDiskConfig -SkuName Premium_LRS -Location $location -CreateOption Copy -SourceResourceId $snapshotinfo3.Id -MaxSharesCount 3
$newDisk3 = New-AzDisk -DiskName $DiskName3 -Disk $diskConfig3 -ResourceGroupName $ResourceGroup

$snapshotinfo4 = Get-AzSnapshot -ResourceGroupName $ResourceGroup -SnapshotName $snapshotName4
$diskConfig4 = New-AzDiskConfig -SkuName Premium_LRS -Location $location -CreateOption Copy -SourceResourceId $snapshotinfo4.Id -MaxSharesCount 3
$newDisk4 = New-AzDisk -DiskName $DiskName4 -Disk $diskConfig4 -ResourceGroupName $ResourceGroup

$snapshotinfo5 = Get-AzSnapshot -ResourceGroupName $ResourceGroup -SnapshotName $snapshotName5
$diskConfig5 = New-AzDiskConfig -SkuName Premium_LRS -Location $location -CreateOption Copy -SourceResourceId $snapshotinfo5.Id -MaxSharesCount 3
$newDisk5 = New-AzDisk -DiskName $DiskName5 -Disk $diskConfig5 -ResourceGroupName $ResourceGroup

$snapshotinfo6 = Get-AzSnapshot -ResourceGroupName $ResourceGroup -SnapshotName $snapshotName6
$diskConfig6 = New-AzDiskConfig -SkuName Premium_LRS -Location $location -CreateOption Copy -SourceResourceId $snapshotinfo6.Id -MaxSharesCount 3
$newDisk6 = New-AzDisk -DiskName $DiskName6 -Disk $diskConfig6 -ResourceGroupName $ResourceGroup

$snapshotinfo7 = Get-AzSnapshot -ResourceGroupName $ResourceGroup -SnapshotName $snapshotName7
$diskConfig7 = New-AzDiskConfig -SkuName Premium_LRS -Location $location -CreateOption Copy -SourceResourceId $snapshotinfo7.Id -MaxSharesCount 3
$newDisk7 = New-AzDisk -DiskName $DiskName7 -Disk $diskConfig7 -ResourceGroupName $ResourceGroup

$snapshotinfo8 = Get-AzSnapshot -ResourceGroupName $ResourceGroup -SnapshotName $snapshotName8
$diskConfig8 = New-AzDiskConfig -SkuName Premium_LRS -Location $location -CreateOption Copy -SourceResourceId $snapshotinfo8.Id -MaxSharesCount 3
$newDisk8 = New-AzDisk -DiskName $DiskName8 -Disk $diskConfig8 -ResourceGroupName $ResourceGroup

$snapshotinfo9 = Get-AzSnapshot -ResourceGroupName $ResourceGroup -SnapshotName $snapshotName9
$diskConfig9 = New-AzDiskConfig -SkuName Premium_LRS -Location $location -CreateOption Copy -SourceResourceId $snapshotinfo9.Id -MaxSharesCount 3
$newDisk9 = New-AzDisk -DiskName $DiskName9 -Disk $diskConfig9 -ResourceGroupName $ResourceGroup


##### Add Shared Data Disks To VMs ####

$disk1 = Get-AzDisk -ResourceGroupName $ResourceGroup -DiskName $DiskName1
$disk2 = Get-AzDisk -ResourceGroupName $ResourceGroup -DiskName $DiskName2
$disk3 = Get-AzDisk -ResourceGroupName $ResourceGroup -DiskName $DiskName3
$disk4 = Get-AzDisk -ResourceGroupName $ResourceGroup -DiskName $DiskName4
$disk5 = Get-AzDisk -ResourceGroupName $ResourceGroup -DiskName $DiskName5
$disk6 = Get-AzDisk -ResourceGroupName $ResourceGroup -DiskName $DiskName6
$disk7 = Get-AzDisk -ResourceGroupName $ResourceGroup -DiskName $DiskName7
$disk8 = Get-AzDisk -ResourceGroupName $ResourceGroup -DiskName $DiskName8
$disk9 = Get-AzDisk -ResourceGroupName $ResourceGroup -DiskName $DiskName9
$vm = Get-AzVM -Name $vmName1 -ResourceGroupName $ResourceGroup
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 0 -VM $vm -ManagedDiskId $disk1.Id
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 1 -VM $vm -ManagedDiskId $disk2.Id
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 2 -VM $vm -ManagedDiskId $disk3.Id
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 3 -VM $vm -ManagedDiskId $disk4.Id
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 4 -VM $vm -ManagedDiskId $disk5.Id
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 5 -VM $vm -ManagedDiskId $disk6.Id
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 6 -VM $vm -ManagedDiskId $disk7.Id
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 7 -VM $vm -ManagedDiskId $disk8.Id
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 8 -VM $vm -ManagedDiskId $disk9.Id
Update-AzVM -VM $vm -ResourceGroupName $ResourceGroup


$vm = Get-AzVM -Name $vmName2 -ResourceGroupName $ResourceGroup
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 0 -VM $vm -ManagedDiskId $disk1.Id
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 1 -VM $vm -ManagedDiskId $disk2.Id
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 2 -VM $vm -ManagedDiskId $disk3.Id
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 3 -VM $vm -ManagedDiskId $disk4.Id
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 4 -VM $vm -ManagedDiskId $disk5.Id
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 5 -VM $vm -ManagedDiskId $disk6.Id
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 6 -VM $vm -ManagedDiskId $disk7.Id
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 7 -VM $vm -ManagedDiskId $disk8.Id
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 8 -VM $vm -ManagedDiskId $disk9.Id
Update-AzVM -VM $vm -ResourceGroupName $ResourceGroup


$vm = Get-AzVM -Name $vmName3 -ResourceGroupName $ResourceGroup
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 0 -VM $vm -ManagedDiskId $disk1.Id
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 1 -VM $vm -ManagedDiskId $disk2.Id
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 2 -VM $vm -ManagedDiskId $disk3.Id
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 3 -VM $vm -ManagedDiskId $disk4.Id
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 4 -VM $vm -ManagedDiskId $disk5.Id
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 5 -VM $vm -ManagedDiskId $disk6.Id
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 6 -VM $vm -ManagedDiskId $disk7.Id
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 7 -VM $vm -ManagedDiskId $disk8.Id
$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 8 -VM $vm -ManagedDiskId $disk9.Id
Update-AzVM -VM $vm -ResourceGroupName $ResourceGroup