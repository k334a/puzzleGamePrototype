extends "res://world.gd"

@onready var grabbed: Array[Resource] = []
var grabNumber: int = 2

func _ready() -> void:
	for item in get_tree().get_nodes_in_group("pickup"):
		item.picked_up.connect(_item_picked_up)

func _item_picked_up(item) -> void:
	grabbed.push_back(item)
	if grabbed.size() == grabNumber:
		for tile in $TileMapLayer.get_used_cells():
			var data: TileData = $TileMapLayer.get_cell_tile_data(tile)
			if data:
				if data.terrain_set == 0 and data.terrain == 2:
					$TileMapLayer.erase_cell(tile)
