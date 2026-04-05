class_name level_save_data
extends Resource

var levelNamesDict: Dictionary[String, Dictionary] = {
	"LevelOne": {},
	"LevelTwo": {},
	"NewTestScene": {},
	"CityScape": {},
	"AlleyWay": {},
	"Greenhouse1": {},
	"GreenhouseArea": {},
	"LeakyBuilding": {},
	"Warehouse": {},
	"Building1": {},
	"Hub": {},
	"Tutorial": {},
	"ElevatorShaft": {},
	"Floor1": {},
	"WarehouseMain": {},
	"WarehouseOffice": {},
	"WarehouseVents": {}
	}

var levelNamesArr: Dictionary[String, Array] = {
	"LevelOne": [],
	"LevelTwo": [],
	"NewTestScene": [],
	"CityScape": [],
	"AlleyWay": [],
	"Greenhouse1": [],
	"GreenhouseArea": [],
	"LeakyBuilding": [],
	"Warehouse": [],
	"Building1": [],
	"Hub": [],
	"Tutorial": [],
	"ElevatorShaft": [],
	"Floor1": [],
	"WarehouseMain": [],
	"WarehouseOffice": [],
	"WarehouseVents": []
	}

@export var jars_status: Dictionary[String, Dictionary] = levelNamesDict.duplicate(true) # {sceneName (String): {jar (NodePath): broken (bool)}}
@export var damaged_areas: Dictionary[String, Dictionary] = levelNamesDict.duplicate(true) # {sceneName (String): {area (NodePath): damageLevel (int)}}
@export var unlocked_entrances: Dictionary[String, Dictionary] = levelNamesDict.duplicate(true) # {sceneName (String): {area (NodePath): unlocked (bool)}}
@export var floating_items: Dictionary[String, Dictionary] = levelNamesDict.duplicate(true) # {sceneName (String): {item (Item): position (Vector2)}}
@export var tempEntrances: Dictionary[String, Array] = levelNamesArr.duplicate(true) # {sceneInName (String): [sceneFromName (String)]}
