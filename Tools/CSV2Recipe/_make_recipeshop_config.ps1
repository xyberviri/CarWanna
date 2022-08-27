<#
    CarWanna, Recipe Shop Config Creator..

   This is the function you will need to change to create whatever custom recipe you want to use for players to create the pinkslips. 

   Typically this is a radio or something else to create the item. 

   Pay carful Attention to the @" and "@ on lines 13 and 23 those need to be there.
#>
function Get-Recipe
{
Param ([string]$item, [string]$name, [int]$price=20)
@"
    recipe Buy $name `$$price
    {
        Money=$price,
        Result: $item,
        Time: 100,
        keep HamRadio1/HamRadio2/HamRadioMakeShift,
        Category: CarShop,        
        CanBeDoneFromFloor:true,
    }
"@
}

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

try {
# Get Input
$here = (Get-Location).Path
$input = get-content (Get-FileName($here))

} catch {
write-host "No input given."
exit 0
}

$CreateRecipe = @()
$CreateRecipe +=@"
module Base {
    imports
    {
        PinkSlip
    }
        
"@
foreach ($line in $input)
{
    $parts = $line -split ','
    $CreateRecipe += Get-Recipe -item ([string]::Format("{0}.{1}",$parts[0],$parts[1])) -name $parts[2] -price $parts[3]
}
$CreateRecipe += "`n`n}"

$prefix=GetNextID

Out-File -FilePath ([string]::Format("{0}\{1}_{2}",$PSScriptRoot,$prefix,"shops.txt")) -InputObject $CreateRecipe -Encoding Ascii
write-host "Copy located at: "([string]::Format("{0}\{1}_{2}",$PSScriptRoot,$prefix,"shops.txt"))