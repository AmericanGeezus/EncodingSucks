#AGent URL, this must be configured on a per-client basis
New-EventLog -LogName Application -Source "N-Central Installer Script"
Write-EventLog "Application" -Source "N-Central Installer Script" -EventId 0 -Message "N-Central Installer Script has been invoked."
[System.URI]$AgentURL = "https://ncentral.501commons.org/dms/FileDownload?customerID=307&softwareID=101"
$ParsedQueryString = [System.Web.HttpUtility]::ParseQueryString($AgentURL.Query)

#Generate architecture-specific path to agent executable
$setupExecutableName = "$($ParsedQueryString[0])WindowsAgentSetup.exe"
"Client specific agent installer: $setupExecutableName"
$file = "\N-able Technologies\Windows Agent\bin\agent.exe"
[Bool]$flag = $false
$fullPath = ""
if ((Get-WmiObject win32_operatingsystem | Select-Object osarchitecture).osarchitecture -eq "64-bit")
{
    $fullPath = Join-Path -Path  $Env:ProgramFiles -ChildPath $file
    if(Test-Path $fullPath -PathType Leaf){
        $flag = $true
    }
}
else
{
    $fullPath = Join-Path -Path 'C:\Program Files (x86)' -ChildPath $file
    if(Test-Path $fullPath -PathType Leaf){
        $flag = $true
    }
}

#Use enviroment temp directory if it exists, or make C:\temp
if($env:TEMP){
    $temp = $env:TEMP
    "Temp directory exists."
}Else{
    New-Item -Path C:\Temp -ItemType Directory
    $temp = "C:\Temp"
}


if($flag -eq $false){
    #if not, download and install agent
    $output = "$temp\$setupExecutableName"
    Invoke-WebRequest -Uri $AgentURL -OutFile $output
    Start-Process -FilePath $output -ArgumentList "-ai" -Wait
    if(Test-Path $fullPath -PathType Leaf){
    Write-EventLog "Application" -Source "N-Central Installer Script" -EventId 1 -Message "Installer Script invoked installer has exited. Install may have completed."
    }Else{
    Write-EventLog "Application" -Source "N-Central Installer Script" -EventId 3 -Message "Installer Script invoked installer has exited, but agent directory check has failed. Verify install completed."
    }
}Else {    
    Write-EventLog "Application" -Source "N-Central Installer Script" -EventId 2 -Message "Agent is already installed."
}