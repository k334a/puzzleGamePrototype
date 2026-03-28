extends Area2D

@onready var freezeRadius: int = ceil(float($CollisionShape2D.shape.radius) / 36.0) #36 is size of tiles, should be edited later

signal freezeTile

func startFreeze() -> void:
	show()
	%FreezeDuration.start()

func reset() -> void:
	hide()
	%FreezeDuration.stop()

func _on_freeze_duration_timeout() -> void:
	hide()

func freeze_check(innerCheck: bool=false) -> void:
	
	var layer: TileMapLayer = get_overlapping_bodies().front()
	
	# Gets a tile in local coordinates of TileMapLayer for center of bubble
	var centerTile: Vector2i = layer.local_to_map(layer.to_local(global_position))
	
	var flatWater: Array[Vector2i] = []
	var flatIce: Array[Vector2i] = []
	var fallingWater: Dictionary[int, Array] = {}
	var fallingIce: Array[int] = []
	
	var tiles: Array[Vector2i]
	var corners: Array[int] # Only necessary if the bubble size changes, current radius doesn't cause corners
	
	if not innerCheck:
		# Builds circle perimeter
		for row in range(ceil(sqrt(freezeRadius * sqrt(0.5))), 0, -1):
			var diameter: int = floor(sqrt(freezeRadius**2 - row**2))
			
			if row == abs(diameter): # Avoids corners being added more than once
				corners.push_back(row)
				continue
			
			# Changing the order of these will mess up the freezing somewhat
			tiles.push_back(centerTile + Vector2i(-diameter, row))
			tiles.push_back(centerTile + Vector2i(diameter, row))
			tiles.push_back(centerTile + Vector2i(diameter, -row))
			tiles.push_back(centerTile + Vector2i(-diameter, -row))
			tiles.push_back(centerTile + Vector2i(-row, diameter))
			tiles.push_back(centerTile + Vector2i(row, diameter))
			tiles.push_back(centerTile + Vector2i(row, -diameter))
			tiles.push_back(centerTile + Vector2i(-row, -diameter))
		
		# Adds in any corners
		for corner in corners:
			tiles.push_back(centerTile + Vector2i(corner, corner))
			tiles.push_back(centerTile + Vector2i(-corner, corner))
			tiles.push_back(centerTile + Vector2i(-corner, -corner))
			tiles.push_back(centerTile + Vector2i(corner, -corner))
		
		# Edges of circle
		tiles.push_back(centerTile + Vector2i(-freezeRadius, 0))
		tiles.push_back(centerTile + Vector2i(freezeRadius, 0))
		tiles.push_back(centerTile + Vector2i(0, -freezeRadius))
		tiles.push_back(centerTile + Vector2i(0, freezeRadius))
	else:
		tiles.push_back(centerTile + Vector2i(floor(float(-freezeRadius) / 2.0), floor(float(-freezeRadius) / 2.0)))
		tiles.push_back(centerTile + Vector2i(floor(float(freezeRadius) / 2.0), floor(float(freezeRadius) / 2.0)))
		tiles.push_back(centerTile + Vector2i(floor(float(freezeRadius) / 2.0), floor(float(-freezeRadius) / 2.0)))
		tiles.push_back(centerTile + Vector2i(floor(float(-freezeRadius) / 2.0), floor(float(freezeRadius) / 2.0)))
	
	# Checks each tile for if it is water or falling water
	for tile in tiles:
		match check_data(tile, layer, "terrain_type"):
			"ice":
				if check_data(tile, layer, "falling"):
					if tile.x not in fallingIce:
						fallingIce.append(tile.x)
				else:
					flatIce.append(tile)
			"water":
				if check_data(tile, layer, "falling"):
					fallingWater.get_or_add(tile.x, []).append(tile.y)
				else:
					flatWater.append(tile)
			_:
				continue
	
	freezeTile.emit(flatWater, flatIce, fallingWater, fallingIce)

func check_data(tile: Vector2i, layer: TileMapLayer, attribute: String) -> Variant:
	var data: TileData = layer.get_cell_tile_data(tile)
	if data and data.has_custom_data(attribute):
		return data.get_custom_data(attribute)
	return null
