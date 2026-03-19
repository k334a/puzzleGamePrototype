extends Node

@export var nextLevel: PackedScene

var frozenTiles: Array[Vector2i]
var removedFallingWater: Array[Vector2i]

func _on_cat_reset_level() -> void:
	#Gets rid of hardcoded distances in TileSet, right now looks weird because terrains I set up are janky
	$TileMapLayer.set_cells_terrain_connect(frozenTiles, 1, 0)
	frozenTiles.clear()
	$TileMapLayer.set_cells_terrain_connect(removedFallingWater, 1, 0)
	removedFallingWater.clear()

func _on_cat_freeze_tile(tile: Vector2i, body: TileMapLayer) -> void:
	frozenTiles.append(tile)
	if body.get_cell_tile_data(tile).get_custom_data("fallingWater"):
		var nextTile: Vector2i = body.get_neighbor_cell(tile, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
		var waterPath: Array[Vector2i]
		
		while nextTile and body.get_cell_tile_data(nextTile).get_custom_data("fallingWater"):
			waterPath.push_back(nextTile)
			nextTile = body.get_neighbor_cell(nextTile, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
		
		while not waterPath.is_empty():
			var removedCell = waterPath.pop_back()
			body.erase_cell(removedCell)
			removedFallingWater.push_back(removedCell)
			


func _on_next_level_placeholder_body_entered(body: Node2D) -> void:
	get_tree().call_deferred("change_scene_to_packed", nextLevel)
