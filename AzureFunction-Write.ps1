

# Parameter Name must match bindings
param($eventGridEvent, $TriggerMetadata)

# Logging data, informational only
# log eventGridEvent in one output stream
write-output "## eventGridEvent ##"
$eventGridEvent | out-string | Write-Output

# Data Type
write-output "## Get-Member ##"
$eventGridEvent | Get-Member | Out-string | Write-Output

# output as JSON
write-output "## eventGridEvent.json ##"
$eventGridEvent | convertto-json | Write-Output

# Declarations

# Set the default error action
$errorActionDefault = $ErrorActionPreference

# Channel Webhook. 
$ChannelURL = "https://outlook.office.com/webhook/a08b9824-b4bb-460c-bbd0-1fb989d78fae@7eaabc33-8728-4f89-bc27-f023795e938a/IncomingWebhook/7eff6e46ede04fb18d28ec448ba1bfcb/2151ab8a-4afe-4310-96ee-3a4ce9bc68a2"

# Get the subscription
try {
    $ErrorActionPreference = 'stop'
    $SubscriptionId = $eventGridEvent.data.subscriptionId
}
catch {
    $ErrorMessage = $_.Exception.message
    write-error ('Error getting Subscription ID ' + $ErrorMessage)
    Break
}
Finally {
    $ErrorActionPreference = $errorActionDefault
}

# Set the ActivityTitle (name of resource) and ActivityType (type of resource)
# Based on they filter set in Event Grid 
if ($eventGridEvent.data.authorization.action -like "Microsoft.Compute/virtualMachines/write") {
    # Set the type of resource created
    $ActivityType = "Server"

    # Set the image used for the message.  
    # leave blank for no image
    $image = ""

    # Get the server name
    try {
        $ErrorActionPreference = 'stop'
        $subjectSplit = $eventGridEvent.subject -split '/'
        $typeName = $subjectSplit[8]
    }
    catch {
        $ErrorMessage = $_.Exception.message
        write-error ('Error getting Resource Group name ' + $ErrorMessage)
        Break
    }
    Finally {
        $ErrorActionPreference = $errorActionDefault
    }
}
elseif ($eventGridEvent.data.authorization.action -like "Microsoft.Network/virtualNetworks/write") {
    # Set the type of resource created
    $ActivityType = "VNET"

    # Set the image used for the message.  
    # leave blank for no image
    $image = ""

    # Get the server name
    try {
        $ErrorActionPreference = 'stop'
        $subjectSplit = $eventGridEvent.subject -split '/'
        $typeName = $subjectSplit[8]
    }
    catch {
        $ErrorMessage = $_.Exception.message
        write-error ('Error getting Resource Group name ' + $ErrorMessage)
        Break
    }
    Finally {
        $ErrorActionPreference = $errorActionDefault
    }
}
elseif ($eventGridEvent.data.authorization.action -like "Microsoft.Network/virtualNetworks/subnets/write") {
    # Set the type of resource created
    $ActivityType = "Subnet"

    # Set the image used for the message.  
    # leave blank for no image
    $image = ""

    # Get the server name
    try {
        $ErrorActionPreference = 'stop'
        $subjectSplit = $eventGridEvent.subject -split '/'
        $typeName = $subjectSplit[8]
    }
    catch {
        $ErrorMessage = $_.Exception.message
        write-error ('Error getting Resource Group name ' + $ErrorMessage)
        Break
    }
    Finally {
        $ErrorActionPreference = $errorActionDefault
    }
}
elseif ($eventGridEvent.data.authorization.action -like "Microsoft.Resources/subscriptions/resourceGroups/write" ) {
    # Set the type of resource created
    $ActivityType = "Resource Group"

    # Set the image used for the message.  
    # leave blank for no image
    $image = ""

    # Get Resource Group
    try {
        $ErrorActionPreference = 'stop'
        $subjectSplit = $eventGridEvent.subject -split '/'
        $typeName = $subjectSplit[4]
    }
    catch {
        $ErrorMessage = $_.Exception.message
        write-error ('Error getting Resource Group name ' + $ErrorMessage)
        Break
    }
    Finally {
        $ErrorActionPreference = $errorActionDefault
    }
}
else {
    write-error 'No activity type defined in script.  Verfiy Event Grid Filter matches IF statement'
    Break
}

<#
# Used for testing
Write-Output '## Type Name ##'
Write-Output $typeName
Write-Output '## Subscription ##'
Write-Output $SubscriptionId
Write-Output '## name ##'
Write-Output $eventGridEvent.data.claims.name
#>

# Send Data to Teams
# Build the message body
$TargetURL = "https://portal.azure.com/#resource" + $eventGridEvent.data.resourceUri + "/overview"   
try {    
    $Body = ConvertTo-Json -ErrorAction Stop -Depth 4 @{
        title           = 'Azure Resource Creation Notification From Azure Functions' 
        text            = 'A new Azure ' + $activityType + ' has been created'
        sections        = @(
            @{
                activityTitle    = 'New Azure ' + $ActivityType
                activitySubtitle = 'Azure ' + $ActivityType + ' named ' + $typeName + ' has been created.'
                activityText     = 'An Azure ' + $ActivityType + ' was created in the subscription ' + $SubscriptionId + ' by ' + $eventGridEvent.data.claims.name
                activityImage    = $image
            }
        )
        potentialAction = @(@{
                '@context' = 'http://schema.org'
                '@type'    = 'ViewAction'
                name       = 'Click here to manage the Resource Group'
                target     = @($TargetURL)
            })
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    write-error ('Error converting body to JSON ' + $ErrorMessage)
    Break
}
           
# call Teams webhook
try {
    write-output '## Invoke-ResgtMethod ##'
    Invoke-RestMethod -Method "Post" -Uri $ChannelURL -Body $Body | Write-output
}
catch {
    $ErrorMessage = $_.Exception.message
    write-error ('Error with invoke-restmethod ' + $ErrorMessage)
    Break
}