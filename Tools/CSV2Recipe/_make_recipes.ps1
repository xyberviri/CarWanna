<#
    CarWanna, Trader Recipe Creator..

   This is the function you will need to change to create whatever custom recipe you want to use for players to create the pinkslips. 

   Typically this is a radio or something else to create the item. 

   Pay carful Attention to the @" and "@ on lines 14 and 25 those need to be there.
   Replace anything in between, to fit your recipe.
#>
function Get-Recipe
{
Param ([string]$item, [string]$name, [int]$price)
@"
    recipe Buy $name `$$price
    {
        Money=$price,
        Result: $item,
        Time: 100,
        keep HamRadio1/HamRadio2/HamRadioMakeShift,
        Category: $global:Category,
        CanBeDoneFromFloor:true,
    }

"@
}

#This is the module that the above recipe goes in. 
#There will be a prompt that allows you to change this. 
$global:ModuleName="Base"

#This is the Category that you buy the pinkslips in. 
$global:Category="CarWanna"






#STUFF BELOW THIS LINE BREAKS IF YOU CHANGE THINGS WITH OUT KNOWING WHAT YOU ARE DOING

#
Function Get-FileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
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
$global:optionModuleName=$false
$global:prefix = GetNextID


try {
    #Assume were in the same path as our csv file.
    $here = (Get-Location).Path

    # Get Input file
    $input = get-content (Get-FileName($here))

    $PackModule = Read-Host -Prompt "Please enter the Module for this config set [$global:ModuleName]"
    if (-not [string]::IsNullOrWhiteSpace($PackModule))
    {
        $global:ModuleName = $PackModule
    }

    $base = Read-Host "Were non 'Base.' vehicle modules added to item names? (most likely no) [no]"
    if ($base -eq 'y' -or $base -eq 'yes')  {
        $global:optionModuleName=$true
    }

    $newCategory = Read-Host -Prompt "Crafting category for buying vehicles: [$global:Category]"
    if (-not [string]::IsNullOrWhiteSpace($newCategory))
    {
        $global:Category
    }

    $newprefix = Read-Host -Prompt "Enter new file prefix to override this random one: [$global:prefix]"
    if (-not [string]::IsNullOrWhiteSpace($newprefix))
    {
        $global:prefix = $newprefix
    }


} catch {
    write-host "No input given."
    exit 0
}



#loop though each line of our csv file
foreach ($line in $input)
{

    $parts        = $line -split ','
    $module       = $parts[0]
    $vehicleID    = $parts[1]
    $friendlyName = $parts[2]
    $cost         = $parts[3]
    $itemName     = $vehicleID

    #If the vehicle doesnt exist in the base module, like Rotars.SemiTruck w900, Was the module added to the item? 
    #ie "PinkSlip.RotarsSemiTruck". This is most likely going to be no.
    if ($module -ne "Base" -and $global:optionModuleName){
        $itemName = $module+$vehicleID 
    }    

    $global:itemNames += [PSCustomObject]@{Item = ([string]::Format("{0}.{1}","PinkSlip",$itemName)); Name = $friendlyName; Vehicle  = "$module.$vehicleID"; Cost=$cost;}
}


$CreateRecipe = @()
$CreateRecipe +=@"
module $global:ModuleName {
    imports
    {
        PinkSlip
    }
        
"@

#Get Recipe for title set.
foreach ($item in $itemNames)
{
    $CreateRecipe += Get-Recipe -item $item.Item -name $item.Name -price $item.Cost
}
$CreateRecipe += "`n`n}"

#Vendor Recipes for Traders
Out-File -FilePath ([string]::Format(".\{0}_{1}",$global:prefix,"shop.txt")) -InputObject $CreateRecipe -Encoding Ascii
write-host "Copy located at: "([string]::Format(".\{0}_{1}",$global:prefix,"shop.txt"))

#Summary Table with items to vehicle mappings, name & price. 
Out-File -FilePath ([string]::Format(".\{0}_{1}",$global:prefix,"summary.txt")) -InputObject $itemNames -Encoding Ascii
write-host "Copy located at: "([string]::Format(".\{0}_{1}",$global:prefix,"summary.txt"))

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
$global:optionModuleName=$false
$global:prefix = GetNextID


try {
    #Assume were in the same path as our csv file.
    $here = (Get-Location).Path

    # Get Input file
    $input = get-content (Get-FileName($here))

    $PackModule = Read-Host -Prompt "Please enter the Module for this config set [$global:ModuleName]"
    if (-not [string]::IsNullOrWhiteSpace($PackModule))
    {
        $global:ModuleName = $PackModule
    }

    $base = Read-Host "Were non 'Base.' vehicle modules added to item names? (most likely no) [no]"
    if ($base -eq 'y' -or $base -eq 'yes')  {
        $global:optionModuleName=$true
    }

    $newprefix = Read-Host -Prompt "Enter new file prefix to override this random one: [$global:prefix]"
    if (-not [string]::IsNullOrWhiteSpace($newprefix))
    {
        $global:prefix = $newprefix
    }

    $newCategory = Read-Host -Prompt "Crafting category for buying vehicles: [$global:Category]"
    if (-not [string]::IsNullOrWhiteSpace($newCategory))
    {
        $global:Category
    }

} catch {
    write-host "No input given."
    exit 0
}



#loop though each line of our csv file
foreach ($line in $input)
{

    $parts        = $line -split ','
    $module       = $parts[0]
    $vehicleID    = $parts[1]
    $friendlyName = $parts[2]
    $cost         = $parts[3]
    $itemName     = $vehicleID

    #If the vehicle doesnt exist in the base module, like Rotars.W900 truck, Was the module added to the item? 
    #ie "PinkSlip.RotarsW900". This is most likely going to be no.
    if ($module -ne "Base" -and $global:optionModuleName){
        $itemName = $module+$vehicleID 
    }
    

    $global:itemNames += [PSCustomObject]@{Item = "$itemName"; Name = $friendlyName; Vehicle  = "$module.$vehicleID"; Cost=$cost;}



}


$CreateRecipe = @()
$CreateRecipe +=@"
module $global:ModuleName {
    imports
    {
        PinkSlip
    }
        
"@

#Get Recipe for title set.
foreach ($item in $itemNames)
{
    $CreateRecipe += Get-Recipe -item ([string]::Format("{0}.{1}","PinkSlip",$item.Item)) -name $item.Name -price $item.Cost
}
$CreateRecipe += "`n`n}"

#Clean up Tiles for export
$itemNames = $itemNames|ForEach-Object {
$_.Item = $global:ModuleName+"."+$_.Item  # replace string in a property
$_                                        # output the object back onto the pipeline
}


#Vendor Recipes for Traders
Out-File -FilePath ([string]::Format(".\{0}_{1}",$global:prefix,"shop.txt")) -InputObject $CreateRecipe -Encoding Ascii
write-host "Copy located at: "([string]::Format(".\{0}_{1}",$global:prefix,"shop.txt"))

#Summary Table with items to vehicle mappings, name & price. 
Out-File -FilePath ([string]::Format(".\{0}_{1}",$global:prefix,"summary.txt")) -InputObject $itemNames -Encoding Ascii
write-host "Copy located at: "([string]::Format(".\{0}_{1}",$global:prefix,"summary.txt"))
