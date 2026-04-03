extends Node

var SCENES: Dictionary[String, Resource] = {
	"level1": load("res://Levels/LevelOne.tscn"),
	"level2": load("res://Levels/LevelTwo.tscn"),
	"testScene": load("res://Levels/NewTestScene.tscn"),
	"cityScape": load("res://Levels/Placeholder Levels/city_scape.tscn"),
	"alleyWay": load("res://Levels/Placeholder Levels/alley_way.tscn"),
	"greenhouse_1": load("res://Levels/Placeholder Levels/greenhouse_1.tscn"),
	"greenhouseArea": load("res://Levels/Placeholder Levels/greenhouse_area.tscn"),
	"leakyBuilding": load("res://Levels/Placeholder Levels/leaky_building.tscn"),
	"warehouse": load("res://Levels/Placeholder Levels/warehouse.tscn"),
	"building1": load("res://Levels/Placeholder Levels/building_1.tscn"),
}
var levelName
var currLevel

var jarsSmashed: Dictionary [String, Dictionary] = {}
var damagedAreas: Dictionary[String, Dictionary] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#print(damagedAreas)

#
#func _on_cat_next_level() -> void:
	#var level = SCENES.get(levelName).instantiate()
	#add_child(level)
	#print(damagedAreas)
	#print(level)
	#for node: interactive_area in level.get_tree().get_nodes_in_group("interaction"):
		#print(node)
		#var area = damagedAreas.get(node)
		#if area:
			#print(area)
			#for _i in range(area+1):
				#node.scratch()
	#currLevel.queue_free()
	#currLevel = level
	#print("HEJ")
	#$cat.position = exitPosition

func _on_set_camera(camera_top_y: int, camera_bottom_x: int, camera_bottom_y: int, camera_top_x: int, zoom: float)-> void:
	$cat.set_camera(camera_top_y, camera_bottom_x, camera_bottom_y, camera_top_x, zoom)
	currLevel.cat = $cat

func _save_level(damagedArea: Dictionary, jarsSmash: Dictionary, levelName2) -> void:
	damagedAreas[levelName2] = damagedArea
	jarsSmashed[levelName2] = jarsSmash
	#print(damagedAreas)

func _load_level(level) -> void:
	level.set_world_values(damagedAreas.get(level.name, {}))
	#print(damagedAreas)
