# healthcheck.ps1
# Example: Check if a specific Windows service is running
$service = Get-Service -Name 'wuauserv' # Windows Update Service for example
if ($service.Status -ne 'Running') {
    exit 1
}
exit 0
