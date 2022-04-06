# CarWanna
Multiplayer car spawning library for Project Zomboid.

https://user-images.githubusercontent.com/1403624/162005443-c79dd891-2bb7-4220-a3de-e9e5748d1420.mp4

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

Item paraments control the spawn conditions of the vehicle:
```
        VehicleID = Base.Van,		         /*  REQUIRED: Change this to the vehicle we want to spawn in */
        Condition = 100,		         /*  Optional Default: random   , this value overrides the repair all of upgraded vehicles */
        GasTank = 100,			         /*  Optional Default: random   , this is the fuel used by the vehicle */
        HasKey = true,                           /*  Optional Default: false    , this is the setting if a key should be spawned */
        Upgraded = false,                        /*  Optional Default: false    , this will add parts that are not normally found on the vehicle and fully repair the vehicle if condition is not set. */
        FuelTank = 100,                          /*  Optional Default: 100      , this is for stored fuel, ie trailers, mostly Ki5.. */
        
```




