FTS = {}
TaxiDestinations = {}

--[[----------------------------------------------
	General Config
-------------------------------------------------]]

FTS.Model = "models/tdmcars/crownvic_taxi.mdl"
FTS.ServerCurrency = "$"

--[[----------------------------------------------
	Admin Logs Config
-------------------------------------------------]]

FTS.AdminInterfaceCommand = "/fts"
FTS.AllowedAdmins = {
	["superadmin"] = true,
	["admin"] = true
}

--[[----------------------------------------------
	Destinations Config
-------------------------------------------------]]

TaxiDestinations[1] = {
	Name = "Taco-Bell",
	Price = 15,
	PosX = 20,
	PosY = 60,
	VectorPos = Vector(-1347.256348, 2969.198975, 600.031250),
	Notify = "You have just paid taxi fares!",
}

TaxiDestinations[2] = {
	Name = "Parking",
	Price = 10,
	PosX = 20,
	PosY = 140,
	VectorPos = Vector(-11200.956055, -4752.150879, -143.968750),
	Notify = "You have just paid taxi fares!",
}