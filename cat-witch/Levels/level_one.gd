extends "res://Levels/world.gd"

@onready var grabbed: Array[Resource] = []
var grabNumber: int = 2

func _ready() -> void:
	for item in get_tree().get_nodes_in_group("pickup"):
		item.picked_up.connect(_item_picked_up)

func _item_picked_up(item) -> void:
	grabbed.push_back(item)
	if grabbed.size() == grabNumber:
		for tile in $TileMapLayer.get_used_cells():
			if check_data(tile, $TileMapLayer, "removable"):
				$TileMapLayer.erase_cell(tile)
