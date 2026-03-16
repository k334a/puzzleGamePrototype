extends Node

@export var nextLevel: PackedScene

var frozenTiles: Array[Vector2i]

func _on_cat_reset_level() -> void:
	for tile in frozenTiles:
		$TileMapLayer.set_cell(tile, $TileMapLayer.get_cell_source_id(tile), $TileMapLayer.get_cell_atlas_coords(tile) + Vector2i(-4, 0), 0)
	frozenTiles.clear()

func _on_cat_freeze_tile(tile: Vector2i) -> void:
	frozenTiles.append(tile)


func _on_next_level_placeholder_body_entered(body: Node2D) -> void:
	get_tree().call_deferred("change_scene_to_packed", nextLevel)
