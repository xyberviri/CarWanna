<#
    CarWanna, Vehicle Config Creator..

   This is the function you will need to change to create whatever custom recipe you want to use for players to create the pinkslips. 

   Typically this is a radio or something else to create the item. 

   Pay carful Attention to the @" and "@ on lines 13 and 23 those need to be there.
#>
function Get-Recipe
{
Param ([string]$item, [string]$name, [int]$price=20)
@"
    recipe Buy $name `$$price,000
    {
        Money1000=$price,
        Result: $item,
        Time: 100,
        keep bm_M21,
        Category: Repo Man,        
        CanBeDoneFromFloor:true,
    }
"@
}

#Base config for carwanna to spawn in the vehicle. 
function Get-AutoTitle
{
    Param ([string]$vehicleID, [string]$friendlyName, [string]$module="Base", [int]$cost=10)

    $itemName = $vehicleID
    if ($module -ne "Base" -and $global:optionModuleName){
        $itemName = $module+$vehicleID 
    }
    $global:itemNames += [PSCustomObject]@{Item = "$itemName"; Name = $friendlyName; Vehicle  = "$module.$vehicleID"; Cost=$cost;}

@"
    item $itemName
    {
        DisplayCategory = CarWanna,
        Weight  = 0.1,
        Type    = Normal,
        Icon    = AutoTitle,
        DisplayName = PinkSlip: $friendlyName,
        VehicleID = $module.$vehicleID,
        WorldStaticModel = CW.AutoTitle,   
        Tooltip = Tooltip_ClaimOutSide,	
        Condition = 100,
        GasTank = 100,
        HasKey = true,
        Tags = PinkSlip,
    }

"@
}

#this is the recipe that actually spawns in the vehicle. 
function Get-ClaimFunction
{
$pinkslips =($global:itemNames| Select -ExpandProperty Item) -join "/" 
@"
module $global:ModuleName
{
    imports
    {
        Base
    }
        
    recipe Claim Vehicle
    {
       $pinkslips,
       Result: Base.CarKey,
       Time: 50.0,
       OnCanPerform:Recipe.OnCanPerform.CW_ClaimVehicle,
       OnCreate:Recipe.OnCreate.CW_ClaimVehicle,
       RemoveResultItem:True,
    } 
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
$PackModule = Read-Host -Prompt "Please enter the Module for this config set [$global:ModuleName]"
if (-not [string]::IsNullOrWhiteSpace($PackModule))
{
    $global:ModuleName = ‘PinkSlip’
}

$base = Read-Host "Add non 'Base.' modules to item names? [no]"
if ($base -eq 'y' -or $base -eq 'yes')  {
    $global:optionModuleName=$true
}





$newprefix = Read-Host -Prompt "New File Prefix or randomized?: [$global:prefix]"
if (-not [string]::IsNullOrWhiteSpace($newprefix))
{
    $global:prefix = $newprefix
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
    $titles += Get-AutoTitle -vehicleID $parts[1] -friendlyName $parts[2] -cost $parts[3] -module $parts[0]
}
$titles += "`n`n}"



$ClaimRecipe = Get-ClaimFunction
$CreateRecipe = @()
$CreateRecipe +=@"
module $global:ModuleName {
    imports
    {
        Base
    }
        
"@

#Get Recipe for title set.
foreach ($item in $itemNames)
{
    $CreateRecipe += Get-Recipe -item ([string]::Format("{0}.{1}",$global:ModuleName,$item.Item)) -name $item.Name -price $item.Cost
}
$CreateRecipe += "`n`n}"



#Clean up Tiles for export
$itemNames = $itemNames|ForEach-Object {
    $_.Item = $global:ModuleName+"."+$_.Item  # replace string in a property
    $_                                           # output the object back onto the pipeline
}

#Dump Files
#Config for Vehicles
Out-File -FilePath ([string]::Format(".\{0}_{1}",$global:prefix,"pinkslips.txt")) -InputObject $titles -Encoding Ascii
write-host "Copy located at: "([string]::Format(".\{0}_{1}",$global:prefix,"pinkslips.txt"))

#Recipe to Spawn Vehicle Set
#Out-File -FilePath ([string]::Format(".\{0}_{1}",$global:prefix,"recipes.txt")) -InputObject $ClaimRecipe -Encoding Ascii
#write-host "Copy located at: "([string]::Format(".\{0}_{1}",$global:prefix,"recipes.txt"))

#Vendor Recipes for Traders
Out-File -FilePath ([string]::Format(".\{0}_{1}",$global:prefix,"shops.txt")) -InputObject $CreateRecipe -Encoding Ascii
write-host "Copy located at: "([string]::Format(".\{0}_{1}",$global:prefix,"shops.txt"))

#Summary Table with items to vehicle mappings, name & price. 
Out-File -FilePath ([string]::Format(".\{0}_{1}",$global:prefix,"summary.txt")) -InputObject $itemNames -Encoding Ascii
write-host "Copy located at: "([string]::Format(".\{0}_{1}",$global:prefix,"summary.txt"))
