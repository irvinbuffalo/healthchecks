# Combined.ps1

# Logging function
function Log-Message {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    
    # Define the log file path
    $logFile = "$env:USERPROFILE\Desktop\deployment_log.txt"
    
    $timestampedMessage = "$(Get-Date) - $Message"
    
    # Write to standard output
    Write-Output $timestampedMessage

    # Append to log file
    Add-Content -Path $logFile -Value $timestampedMessage
}

# Run healthcheck.ps1
$service = Get-Service -Name 'wuauserv' # Windows Update Service for example
if ($service.Status -ne 'Running') {
    Log-Message "ERROR: Windows Update Service is not running!"
    exit 1
}

Log-Message "Healthcheck passed. Proceeding with AD deployment."

# Import AD module for subsequent commands
Import-Module ADDSDeployment

try {
    # Install AD Domain Services
    Log-Message "Installing AD Domain Services..."
    Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

    # Install new forest
    Log-Message "Setting up new AD forest..."
    $domainName = "customera.local"
    $domainNetbiosName = "CUSTOMERA"
    $safeModeAdministratorPassword = ConvertTo-SecureString -AsPlainText "12345qwert!@#$%QWERT" -Force

    Install-ADDSForest `
        -CreateDnsDelegation:$false `
        -DatabasePath "C:\Windows\NTDS" `
        -DomainMode "Win2012R2" `
        -DomainName $domainName `
        -DomainNetbiosName $domainNetbiosName `
        -ForestMode "Win2012R2" `
        -InstallDns:$true `
        -LogPath "C:\Windows\NTDS" `
        -NoRebootOnCompletion:$false `
        -SysvolPath "C:\Windows\SYSVOL" `
        -SafeModeAdministratorPassword $safeModeAdministratorPassword `
        -Force:$true

    Log-Message "Forest setup complete."

    # Create Organizational Units (OUs)
    Log-Message "Creating Organizational Units..."
    # ... [rest of the OU creation commands] ...

    Log-Message "All OUs created."

    #Reboot the VM after the installation
    Log-Message "Rebooting the VM..."
    Restart-Computer -Force

} catch {
    Log-Message "ERROR: $_" # This will print detailed error information
    exit 1
}
