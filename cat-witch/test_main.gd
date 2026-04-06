extends Node

@export var save_data: level_save_data
@export_enum("LevelOne", "LevelTwo", "NewTestScene", "CityScape", "AlleyWay", "Greenhouse1", "GreenhouseArea", "LeakyBuilding", "Warehouse", "Building1", "Hub", "Tutorial", "ElevatorShaft", "Floor1", "WarehouseMain", "WarehouseOffice", "WarehouseVents", "Roof") var startLevel: String = "Tutorial"

var SCENES: Dictionary[String, PackedScene] = {
	"LevelOne": load("res://Levels/LevelOne.tscn"),
	"LevelTwo": load("res://Levels/LevelTwo.tscn"),
	"NewTestScene": load("res://Levels/NewTestScene.tscn"),
	"CityScape": load("res://Levels/Placeholder Levels/city_scape.tscn"),
	"AlleyWay": load("res://Levels/Placeholder Levels/alley_way.tscn"),
	"Greenhouse1": load("res://Levels/Placeholder Levels/greenhouse_1.tscn"),
	"GreenhouseArea": load("res://Levels/Placeholder Levels/greenhouse_area.tscn"),
	"LeakyBuilding": load("res://Levels/Placeholder Levels/leaky_building.tscn"),
	"Warehouse": load("res://Levels/Placeholder Levels/warehouse.tscn"),
	"Building1": load("res://Levels/Placeholder Levels/building_1.tscn"),
	"Hub": load("res://Levels/hub.tscn"),
	"Tutorial": load("res://Levels/Tutorial.tscn"),
	"ElevatorShaft": load("res://Levels/Placeholder Levels/Elevator_Shaft.tscn"),
	"Floor1": load("res://Levels/Placeholder Levels/Floor_1.tscn"),
	"WarehouseMain": load("res://Levels/Placeholder Levels/warehouse_main.tscn"),
	"WarehouseOffice": load("res://Levels/Placeholder Levels/warehouse_office.tscn"),
	"WarehouseVents": load("res://Levels/Placeholder Levels/warehouse_vents.tscn"),
	"Roof": load("res://Levels/Placeholder Levels/roof.tscn"),
}

var currentLevel: String

func _ready() -> void:
	currentLevel = startLevel
	_on_load_level(startLevel, Vector2.ZERO, [], [], [])

func _on_save_level(breakables: Dictionary, damages: Dictionary, unlocks: Dictionary, floating: Dictionary) -> void:
	save_data.jars_status[currentLevel] = breakables
	save_data.damaged_areas[currentLevel] = damages
	save_data.unlocked_entrances[currentLevel] = unlocks
	save_data.floating_items[currentLevel] = floating

func _on_load_level(levelName: String, location: Vector2, spells: Array, items: Array, knownSpells: Array) -> void:
	var level: Node = SCENES.get(levelName).instantiate()
	call_deferred("add_child", level)
	await level.ready
	level.set_up_cat(spells, items, location, knownSpells)
	level.set_up_jars(save_data.jars_status.get(levelName))
	level.set_up_areas(save_data.damaged_areas.get(levelName), save_data.unlocked_entrances.get(levelName), save_data.tempEntrances.get(levelName))
	save_data.tempEntrances[levelName].clear()
	level.set_up_items(save_data.floating_items[levelName])
	level.loadLevel.connect(_on_load_level)
	level.saveLevel.connect(_on_save_level)
	level.unlockEntrance.connect(_on_unlock_entrance)
	currentLevel = levelName

func _on_unlock_entrance(destination: String) -> void:
	save_data.tempEntrances[destination].push_back(currentLevel)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		%PauseMenu.enable()
		get_tree().paused = true

func _on_pause_menu_reset_game() -> void:
	get_tree().paused = false
	save_data.clear()
	get_child(-1).queue_free()
	_on_load_level(startLevel, Vector2.ZERO, [], [], [])

func _on_pause_menu_reset_puzzle() -> void:
	get_tree().paused = false
	var level = get_child(-1)
	level.get_child(level.get_children().find_custom(func(node): return node.is_in_group("player"))).resetCat()

func _on_pause_menu_un_pause() -> void:
	get_tree().paused = false
