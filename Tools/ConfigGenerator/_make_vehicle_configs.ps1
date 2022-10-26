<#
    CarWanna, Vehicle Config Creator..

   This is the function you will need to change to create whatever custom recipe you want to use for players to create the pinkslips. 

   Typically this is a radio or something else to create the item. 

   Pay carful Attention to the @" and "@ on lines 13 and 23 those need to be there.
#>

#Base config for carwanna to spawn in the vehicle. 
function Get-AutoTitle
{
    Param ([string]$vehicleID, [string]$friendlyName, [string]$module="Base",[boolean]$blacklisted=$false,[string]$skin="")
    $isBlacklisted=""
    $skinId=""

    if($blacklisted)
    {
        $isBlacklisted = "`r`n        isBlacklisted = true,"
    }

    $itemName = $vehicleID
    if($skin -ne "")
    {
        $skinId = "`r`n        Skin = $skin,"
        $itemName = [string]::Format("{0}{1}",$vehicleID,$skin)
    }

    
    if ($module -ne "Base" -and $global:optionModuleName){
        $itemName = $module+$vehicleID 
    }

    $global:itemNames += [PSCustomObject]@{Item = "$itemName"; Name = $friendlyName; Vehicle  = "$module.$vehicleID"; Spawns = (-not $blacklisted)}

@"
    item $itemName
    {
        DisplayCategory = CarWanna,
        Weight  = 0.1,
        Type    = Normal,
        Icon    = AutoTitle,
        DisplayName = PinkSlip: $friendlyName,
        VehicleID = $module.$vehicleID,$skinId
        WorldStaticModel = CW.AutoTitle,   
        Tooltip = Tooltip_ClaimOutSide,	
        Condition = 100,
        EngineQuality = 100,
        GasTank = 100,
        TirePSI = 100,
        Battery = 1,
        HasKey = true,
        Tags = PinkSlip,$isBlacklisted
    }

"@
}



#
Function Get-FileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    #(*.bmp, *.jpg)|*.bmp;*.jpg
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "Vehicle List (*.txt, *.csv)| *.txt;*.csv|TXT (*.txt)| *.txt|CSV (*.csv)| *.csv|ALL Files (*.*)| *.*"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

function GetNextID($maxSize = 5)
{
    $g = [guid]::NewGuid()
    $v = [string]$g
    $v = $v.Replace("-", "")
    return $v.substring(0, $maxSize)
}






$global:itemNames = @()
$global:ModuleName="PinkSlip"
$global:optionModuleName=$false
$global:prefix = GetNextID



try {
# Get Input
$here = (Get-Location).Path
$input = get-content (Get-FileName($here))

$newprefix = Read-Host -Prompt "Enter File Prefix or hit enter to accept randomized: [$global:prefix]"
if (-not [string]::IsNullOrWhiteSpace($newprefix))
{
    $global:prefix = $newprefix
}

$base = Read-Host "Add non 'Base.' modules to item names? [no]"
if ($base -ieq 'y' -or $base -ieq 'yes')  {
    $global:optionModuleName=$true
}



} catch {
write-host "No input given."
exit 0
}



$titles = @()
$titles +=@"
module $global:ModuleName {
    imports
    {
        Base
    }
        
"@
$count = 0
foreach ($line in $input)
{
    $count += 1
    $parts = $line -split ','
    $skinid = $null

    if(-not [string]::IsNullOrWhiteSpace($parts[3]) ){
            $parts[3] = ($parts[3] -ieq "true")
        }
    if($parts.Count -gt 3 -and (-not [string]::IsNullOrWhiteSpace($parts[4])) ){
            $skinid = $parts[4]
        }

    $titles += Get-AutoTitle -module $parts[0] -vehicleID $parts[1] -friendlyName $parts[2] -blacklisted ($parts[3] -ieq "true") -skin $skinid
}
$titles += "`n`n}"


#Clean up Tiles for export
$itemNames = $itemNames|ForEach-Object {
    $_.Item = $global:ModuleName+"."+$_.Item  # replace string in a property
    $_                                           # output the object back onto the pipeline
}

#Dump Files
#Config for Vehicles
Out-File -FilePath ([string]::Format(".\{0}_{1}",$global:prefix,"pinkslips.txt")) -InputObject $titles -Encoding Ascii
write-host "Copy located at: "([string]::Format(".\{0}_{1}",$global:prefix,"pinkslips.txt"))


#Summary Table with items to vehicle mappings, name & price. 
Out-File -FilePath ([string]::Format(".\{0}_{1}",$global:prefix,"PinkSlipList.txt")) -InputObject $itemNames -Encoding Ascii
write-host "Copy located at: "([string]::Format(".\{0}_{1}",$global:prefix,"PinkSlipList.txt"))
