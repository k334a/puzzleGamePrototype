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

func _on_cat_freeze_tile(freezeTiles: Array[Vector2i], fallingTiles: Dictionary[int, Array], layer: TileMapLayer) -> void:
	print(freezeTiles)
	print(fallingTiles)
	for x in fallingTiles:
		var waterStream: Array = fallingTiles[x]
		waterStream.sort()
		for y in waterStream:
			freezeTiles.append(Vector2i(x, y))
	#frozenTiles.append_array(freezeTiles)
	#layer.set_cells_terrain_connect(freezeTiles, 1, 1)
	#freezeTiles.clear()
	
	for x in fallingTiles:
		print("x: ", x)
		var waterStream: Array = fallingTiles[x]
		var aboveTile: Vector2i = layer.get_neighbor_cell(Vector2i(x, waterStream.front()), TileSet.CELL_NEIGHBOR_TOP_SIDE)
		print("above1: ",aboveTile)
		while aboveTile and layer.get_cell_tile_data(aboveTile) and layer.get_cell_tile_data(aboveTile).get_custom_data("freezable"):
			freezeTiles.append(aboveTile)
			aboveTile = layer.get_neighbor_cell(aboveTile, TileSet.CELL_NEIGHBOR_TOP_SIDE)
			print("above: ",aboveTile)
		var belowTile: Vector2i = layer.get_neighbor_cell(Vector2i(x, waterStream.back()), TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
		print("below1: ",belowTile)
		if belowTile and layer.get_cell_tile_data(belowTile) and layer.get_cell_tile_data(belowTile).get_custom_data("fallingWater"):
			freezeTiles.append(belowTile)
			belowTile = layer.get_neighbor_cell(belowTile, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
			print("below: ",belowTile)
		while belowTile and layer.get_cell_tile_data(belowTile) and layer.get_cell_tile_data(belowTile).get_custom_data("fallingWater"):
			removedFallingWater.append(belowTile)
			layer.erase_cell(belowTile)
			belowTile = layer.get_neighbor_cell(belowTile, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
			print("below: ",belowTile)
		
	frozenTiles.append_array(freezeTiles)
	layer.set_cells_terrain_connect(freezeTiles, 1, 1)
	
	#for tile in tiles:
		#if layer.get_cell_tile_data(tile).get_custom_data("fallingWater"):
			#frozenTiles.append(tile)
			#var nextTile: Vector2i = layer.get_neighbor_cell(tile, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
			#while nextTile and layer.get_cell_tile_data(nextTile) and layer.get_cell_tile_data(nextTile).get_custom_data("fallingWater"):
				#removedFallingWater.push_back(nextTile)
				#if tiles.find(nextTile) != -1:
					#tiles.remove_at(tiles.find(nextTile))
				#layer.erase_cell(nextTile)
				#nextTile = layer.get_neighbor_cell(nextTile, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
		#else:
			#frozenTiles.append(tile)
	#layer.set_cells_terrain_connect(tiles, 1, 1)



func _on_next_level_placeholder_body_entered(body: Node2D) -> void:
	get_tree().call_deferred("change_scene_to_packed", nextLevel)
