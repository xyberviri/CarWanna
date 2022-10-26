$global:filenameout = ""
function Get-FileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "CSV,LUA (*.csv, *.lua)| *.csv;*.lua|INPUT (*.csv)| *.csv|OUTPUT (*.lua)| *.lua|ALL Files (*.*)| *.*"    
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

<#
Shop.Items["AuthenticZClothing.Hat_CheeseHat"] = {
    tab = Tab.Special, price = 1, specialCoin = true,
}
#>

function Get-NShopBuyRecipe
{
Param ([string]$item, [string]$name, [string]$tab, [int]$price, [int]$quantity=1,[boolean]$special=$false)
$quantity_string = ""
$special_string = ""
if($quantity -gt 1)
    {
        $quantity_string = " quantity = $quantity,"
    }
if($special)
    {
        $special_string = " specialCoin = true,"
    }
if($name -ne "")
    {
        $name = "--$name`r`nShop"
    } else
    {
        $name = "Shop"
    }
@"
$name.Items["$item"] = {
    tab = Tab.$tab, price = $price,$quantity_string$special_string
}

"@
}

function Get-NShopSellRecipe
{
Param ([string]$item, [string]$name, [int]$price, [boolean]$special=$false,[boolean]$blacklisted=$false)
    $content="blacklisted = true"
    if (-not $blacklisted){
        $special_string = ""
        if($special){
            $special_string = " , specialCoin = true"
        }
        $content="price = $price$special_string"
    }

    if($name -ne ""){
        $name = " --$name"
    }
@"
    ["$item"] = { $content },$name
"@

}

try {
# Open window
    $here = (Get-Location).Path
    $filename = Get-FileName($here)
    write-host "Input file:" (Split-Path $filename -leaf)

    #$global:filenameout = Split-Path $filename -leaf
    $global:filenameout = ([string]::Format("{0}{1}",(Get-Item $filename).Basename,".lua"))

    $input = (get-content $filename| Select -Skip 1)
    $newfilename = Read-Host -Prompt "Enter a output file or hit enter to accept the default:[$global:filenameout]"


    if (-not [string]::IsNullOrWhiteSpace($newfilename))
    {
        $global:filenameout = $newfilename
    }


} catch {
    write-host "No input given."
    exit 0
}



$fileoutput = @()
$fileoutput += ([string]::Format("{0}{1}","--",(Split-Path $filename -leaf)))
$buysell = Read-Host "Are you creating the 'Sales' list?, (hit enter for 'no' or type 'yes'): "

##START SALES##
if ($buysell -ieq 'y' -or $buysell -ieq 'yes')
{
    write-host "Creating Sales list"

$fileoutput +=@"
Shop.defaultPrice = 5 -- Default sell price for items 
Shop.defaultPriceBroken = 1 -- Default sell price for broken items
Shop.SellisBlacklist = false -- Use Shop.Sell as blacklist
Shop.SellisWhitelist = true -- Use Shop.Sell as whitelist

Shop.Sell = {
"@

    foreach ($line in $input)
    {
        $parts = $line -split ','
        if($parts.Count -gt 5 -and [string]::IsNullOrWhiteSpace($parts[5]) ){
            $parts[5] = "FALSE"
        }
        if($parts.Count -gt 6 -and  [string]::IsNullOrWhiteSpace($parts[6]) ){
            $parts[6] = "FALSE"
        }
        $CommandArguments = @{
            item = [string]::Format("{0}.{1}",$parts[0],($parts[1] -ireplace [string]::Format("^{0}.",$parts[0]),'')) #Some csv files have the module. notation and others dont, this ensures we support both.
            price = $parts[3]
            special = [System.Convert]::ToBoolean($parts[5])
            blacklisted = [System.Convert]::ToBoolean($parts[6])
            name = $parts[7]
        }    
        $fileoutput += Get-NShopSellRecipe @CommandArguments 
    }

$fileoutput +=@"
}
"@
} 
##END SALES##
##START BUYING##
else 
{
write-host "Creating Buy list"
foreach ($line in $input)
    {
    #PinkSlip,SIXISRhinoTowTruck,SIXIS,1,1,TRUE
        $parts = $line -split ','
        if($parts.Count -gt 5 -and [string]::IsNullOrWhiteSpace($parts[5]) ){
            $parts[5] = "FALSE"
        }
        $CommandArguments = @{
            item = [string]::Format("{0}.{1}",$parts[0],($parts[1] -ireplace [string]::Format("^{0}.",$parts[0]),'')) #Some csv files have the module. notation and others dont, this ensures we support both.
            #item = [string]::Format("{0}.{1}",$parts[0],($parts[1] -replace '^Base.',''))
            tab  = $parts[2] -replace '^Tab.',''
            price = $parts[3]
            quantity = $parts[4]
            special = [System.Convert]::ToBoolean($parts[5])
            name = $parts[6]
        }    
        $fileoutput += Get-NShopBuyRecipe @CommandArguments 
    }
}
##END BUYING##
Out-File -FilePath ([string]::Format(".\{0}",$global:filenameout)) -InputObject $fileoutput -Encoding Ascii
write-host ([string]::Format("Output: .\{0}",$global:filenameout))
