extends Node

@export var nextLevel: PackedScene

# Keeping these as separate for now, but technically shouldn't need to be
var frozenTiles: Array[Vector2i]
var removedFallingWater: Array[Vector2i]

# Can remove this, just added for the sake of my sanity while testing
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Reset"):
		$cat.resetCat()

func _on_cat_reset_level() -> void:
	# Gets rid of hardcoded distances in TileSet, right now looks weird because terrains I set up are janky
	# If we end up adding different tile map layers, this will need to instead be a unique named one or passed in onready
	$TileMapLayer.set_cells_terrain_connect(frozenTiles, 1, 0)
	frozenTiles.clear()
	
	$TileMapLayer.set_cells_terrain_connect(removedFallingWater, 1, 0)
	removedFallingWater.clear()

func _on_cat_freeze_tile(freezeTiles: Array[Vector2i], fallingTiles: Dictionary[int, Array], layer: TileMapLayer) -> void:
	
	for x in fallingTiles: # Iterates through each vertical set of falling water tiles
		var waterStream: Array = fallingTiles[x]
		waterStream.sort()
		
		# Any tiles that were within bubble are added to be frozen
		for y in waterStream:
			freezeTiles.append(Vector2i(x, y))
		
		# Iterates through any freezable tiles above the topmost frozen tile and adds them to be frozen
		var aboveTile: Vector2i = layer.get_neighbor_cell(Vector2i(x, waterStream.front()), TileSet.CELL_NEIGHBOR_TOP_SIDE)
		while aboveTile and layer.get_cell_tile_data(aboveTile) and layer.get_cell_tile_data(aboveTile).get_custom_data("freezable"):
			freezeTiles.append(aboveTile)
			aboveTile = layer.get_neighbor_cell(aboveTile, TileSet.CELL_NEIGHBOR_TOP_SIDE)
		
		# Iterates through any falling water tiles 2 below the bottommost frozen tile and removes them
		var belowTile: Vector2i = layer.get_neighbor_cell(Vector2i(x, waterStream.back()), TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
		# This makes it so that one below the bottom tile is frozen instead of removed
		if belowTile and layer.get_cell_tile_data(belowTile) and layer.get_cell_tile_data(belowTile).get_custom_data("fallingWater"):
			freezeTiles.append(belowTile)
			belowTile = layer.get_neighbor_cell(belowTile, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
		while belowTile and layer.get_cell_tile_data(belowTile) and layer.get_cell_tile_data(belowTile).get_custom_data("fallingWater"):
			removedFallingWater.append(belowTile)
			layer.erase_cell(belowTile)
			belowTile = layer.get_neighbor_cell(belowTile, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
	
	frozenTiles.append_array(freezeTiles)
	layer.set_cells_terrain_connect(freezeTiles, 1, 1)
	

func _on_next_level_placeholder_body_entered(_body: Node2D) -> void:
	get_tree().call_deferred("change_scene_to_packed", nextLevel)
