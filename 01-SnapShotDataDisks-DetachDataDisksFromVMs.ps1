
Connect-AzAccount -Tenant '7eaabc33-8728-4f89-bc27-f023795e938a' -SubscriptionId 'fe688881-14d5-4b7a-985a-10dbcaaf3097'

#### Change Resource Group Name, VM names,104.41.206.205 Disk Names and location #####

$ResourceGroup = "Lab2"
$location = "northeurope"
$VmName1 = "LabVM01"
$VmName2 = "LabVM02"
$VmName3 = "LabVM03"


######### VM01 Snapshot DataDisks ##########

$vm1 = get-azvm -Name $VmName1 -ResourceGroupName $ResourceGroup
$snapshotdisk1 = $vm1.StorageProfile

 Write-Output "VM $($vm1.name) Data Disk Snapshots Begin"
 
    $dataDisks1 = ($snapshotdisk1.DataDisks).name
 
        foreach ($datadisk1 in $datadisks1) {
 
            $dataDisk1 = Get-AzDisk -ResourceGroupName $vm1.ResourceGroupName -DiskName $datadisk1
 
            Write-Output "VM $($vm1.name) data Disk $($datadisk1.Name) Snapshot Begin"
 
            $DataDiskSnapshotConfig1 = New-AzSnapshotConfig -SourceUri $dataDisk1.Id -CreateOption Copy -Location $location
            $snapshotNameData1 = "$($datadisk1.name)_snapshot_$(Get-Date -Format ddMMyy)"
 
                New-AzSnapshot -ResourceGroupName $ResourceGroup -SnapshotName $snapshotNameData1 -Snapshot $DataDiskSnapshotConfig1 -ErrorAction Stop
          
            Write-Output "VM $($vm1.name) data Disk $($datadisk1.Name) Snapshot End"   
        }
 
    Write-Output "VM $($vm1.name) Data Disk Snapshots End" 


    ######### Detach Data Disks #############

$VirtualMachine = Get-AzVM -ResourceGroupName $ResourceGroup -Name $VmName1
Remove-AzVMDataDisk -VM $VirtualMachine -Name "LabVM01_DataDisk_0"
Remove-AzVMDataDisk -VM $VirtualMachine -Name "LabVM01_DataDisk_1"
Remove-AzVMDataDisk -VM $VirtualMachine -Name "LabVM01_DataDisk_2"
Remove-AzVMDataDisk -VM $VirtualMachine -Name "LabVM01_DataDisk_3"
Remove-AzVMDataDisk -VM $VirtualMachine -Name "LabVM01_DataDisk_4"
Remove-AzVMDataDisk -VM $VirtualMachine -Name "LabVM01_DataDisk_5"
Remove-AzVMDataDisk -VM $VirtualMachine -Name "LabVM01_DataDisk_6"
Remove-AzVMDataDisk -VM $VirtualMachine -Name "LabVM01_DataDisk_7"
Remove-AzVMDataDisk -VM $VirtualMachine -Name "LabVM01_DataDisk_8"
Update-AzVM -ResourceGroupName $ResourceGroup -VM $VirtualMachine

$VirtualMachine = Get-AzVM -ResourceGroupName $ResourceGroup -Name $VmName2
Remove-AzVMDataDisk -VM $VirtualMachine -Name "LabVM02_DataDisk_0"
Remove-AzVMDataDisk -VM $VirtualMachine -Name "LabVM02_DataDisk_1"
Remove-AzVMDataDisk -VM $VirtualMachine -Name "LabVM02_DataDisk_2"
Remove-AzVMDataDisk -VM $VirtualMachine -Name "LabVM02_DataDisk_3"
Remove-AzVMDataDisk -VM $VirtualMachine -Name "LabVM02_DataDisk_4"
Remove-AzVMDataDisk -VM $VirtualMachine -Name "LabVM02_DataDisk_5"
Remove-AzVMDataDisk -VM $VirtualMachine -Name "LabVM02_DataDisk_6"
Remove-AzVMDataDisk -VM $VirtualMachine -Name "LabVM02_DataDisk_7"
Remove-AzVMDataDisk -VM $VirtualMachine -Name "LabVM02_DataDisk_8"
Update-AzVM -ResourceGroupName $ResourceGroup -VM $VirtualMachine

$VirtualMachine = Get-AzVM -ResourceGroupName $ResourceGroup -Name $VmName3
Remove-AzVMDataDisk -VM $VirtualMachine -Name "LabVM03_DataDisk_0"
Remove-AzVMDataDisk -VM $VirtualMachine -Name "LabVM03_DataDisk_1"
Remove-AzVMDataDisk -VM $VirtualMachine -Name "LabVM03_DataDisk_2"
Remove-AzVMDataDisk -VM $VirtualMachine -Name "LabVM03_DataDisk_3"
Remove-AzVMDataDisk -VM $VirtualMachine -Name "LabVM03_DataDisk_4"
Remove-AzVMDataDisk -VM $VirtualMachine -Name "LabVM03_DataDisk_5"
Remove-AzVMDataDisk -VM $VirtualMachine -Name "LabVM03_DataDisk_6"
Remove-AzVMDataDisk -VM $VirtualMachine -Name "LabVM03_DataDisk_7"
Remove-AzVMDataDisk -VM $VirtualMachine -Name "LabVM03_DataDisk_8"
Update-AzVM -ResourceGroupName $ResourceGroup -VM $VirtualMachine

