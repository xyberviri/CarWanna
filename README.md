# CarWanna
Multiplayer car spawning library for Project Zomboid.

https://user-images.githubusercontent.com/1403624/162005443-c79dd891-2bb7-4220-a3de-e9e5748d1420.mp4

https://steamcommunity.com/sharedfiles/filedetails/?id=2786560561

See also
https://youtu.be/oXKdxwWSi8I
https://www.youtube.com/watch?v=dEaTzyuOmEM


Vehicles can be spawned directly with LUA:
```
sendClientCommand(player, "CW", "spawnVehicle",  {type = "Base.Van" } )
sendClientCommand(player, "CW", "spawnVehicle",  {type = "Base.Van", condition = 100} )
sendClientCommand(player, "CW", "spawnVehicle",  {type = "Base.Van", condition = 100, gastank = 100  } )
sendClientCommand(player, "CW", "spawnVehicle",  {type = "Base.Van", condition = 100, gastank = 100, fueltank = 100  } )
sendClientCommand(player, "CW", "spawnVehicle",  {type = "Base.Van", condition = 100, gastank = 100, fueltank = 100, makekey = true  } )
sendClientCommand(player, "CW", "spawnVehicle",  {type = "Base.Van", condition = 100, gastank = 100, fueltank = 100, makekey = true, upgrade = true } )
```

Alternatively You can create a vehicle item (aka pinkslip), the recipe will automatically pick up any item with the `PinkSlip` tag:
```
module PinkSlip {
    imports
    {
        Base
    }
        
    item DodgeCC
    {
        DisplayCategory = CarWanna,
        Weight  = 0.1,
        Type    = Normal,
        Icon    = AutoTitle,
        DisplayName = PinkSlip: Dodge Challenger,
        VehicleID = Base.DodgeCC,
        Skin = 0,
        WorldStaticModel = CW.AutoTitle,   
        Tooltip = Tooltip_ClaimOutSide,	
        Condition = 100,
        GasTank = 100,
        FuelTank = 100,
        HasKey = true,
        Tags = PinkSlip,
        isBlacklisted = true,
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
        isBlacklisted= true                    /* These items will not spawn in the loot tables when pinkslip loot is enabled. */
        Skin = 0                                 /* Optional This will specify which skin a vehicle spawns with, not setting this will randomize the skin */
        
```


Naming convention for items are `VehicleName` or `VehicleName#` where the # is the skin a vehicle will spawn.  

