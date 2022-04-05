# CarWanna
Multiplayer car spawning library for Project Zomboid.

https://steamcommunity.com/sharedfiles/filedetails/?id=2786560561


Vehicles can be spawned directly with LUA:
```
sendClientCommand(player, "CW", "spawnVehicle",  {type = "Base.Van" } )
sendClientCommand(player, "CW", "spawnVehicle",  {type = "Base.Van", condition = 100} )
sendClientCommand(player, "CW", "spawnVehicle",  {type = "Base.Van", condition = 100, gastank = 100  } )
sendClientCommand(player, "CW", "spawnVehicle",  {type = "Base.Van", condition = 100, gastank = 100, fueltank = 100  } )
sendClientCommand(player, "CW", "spawnVehicle",  {type = "Base.Van", condition = 100, gastank = 100, fueltank = 100, makekey = true  } )
sendClientCommand(player, "CW", "spawnVehicle",  {type = "Base.Van", condition = 100, gastank = 100, fueltank = 100, makekey = true, upgrade = true } )
```

Alternatively You can create a vehicle item (aka pinkslip) and recipe to call the function to spawn the vehicle NO LUA required:
```
module CW {

    item pinkslip1
    {
        DisplayCategory = CarWanna,
        Weight	=	0.1,
        Type	=	Normal,
        DisplayName	= PinkSlip: Chevalier Nyala,
        Icon	=	AutoTitle,
        WorldStaticModel = CW.AutoTitle,
        VehicleID = Base.CarLights,		
        Condition = 100,
        GasTank = 100,
        HasKey = true,
    }
}
 
module CW
{
    imports
    {
        Base
    }
     
    recipe Claim Vehicle
    {
       pinkslip1/pinkslip2,
       Result: Base.CarKey,
       Time: 50.0,
       OnCanPerform:Recipe.OnCanPerform.CW_ClaimVehicle,
       OnCreate:Recipe.OnCreate.CW_ClaimVehicle,
       RemoveResultItem:True,
    } 
} 


```
