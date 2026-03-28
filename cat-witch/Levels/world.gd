extends Node

@export var nextLevel: PackedScene

@onready var inventory_ui: InventoryUI = $InventoryUI
@onready var cat = $cat

var pushableStartPoints: Array[Vector2]
var breakableStatus: Dictionary[RigidBody2D, bool]

var frozenTiles: Dictionary[Vector2i, float] # { (x,y): time_left }
var frozenStreamsX: Dictionary[int, Array] # { x: [time_left, top_y, bottom_y] }

enum { TERRAIN_SET_FLOOR_WALL, TERRAIN_SET_WATER_ICE }
enum { TERRAIN_FLOOR, TERRAIN_CLIMBABLE, TERRAIN_DISAPPEAR }
enum { TERRAIN_WATER, TERRAIN_FALLING_WATER, TERRAIN_ICE, TERRAIN_FALLING_ICE }

func _ready() -> void:
	for node: RigidBody2D in get_tree().get_nodes_in_group("pushable"):
		pushableStartPoints.push_back(node.global_position)
	for node: RigidBody2D in get_tree().get_nodes_in_group("breakable"):
		breakableStatus.set(node, false)
		node.jar_broken.connect(_on_jar_broken)
	cat.set_camera_bounds(%CameraTopLeft.global_position.y, %CameraBottomRight.global_position.x, %CameraBottomRight.global_position.y, %CameraTopLeft.global_position.x)

func _on_jar_broken(jar: RigidBody2D) -> void:
	breakableStatus.set(jar, true)
	if breakableStatus.values().all(func(jarStatus): return jarStatus):
		print("Broke all jars!")

func _physics_process(delta: float) -> void:
	
	# Can remove this, just added for the sake of my sanity while testing
	if Input.is_action_just_pressed("Reset"):
		cat.resetCat()
	
	if Input.is_action_just_pressed("inventory"):
		inventory_ui.toggle(cat.inventory)
	
	if not frozenTiles.is_empty():
		var toUnfreezeFlat: Array[Vector2i] = []
		var tilesRemove: Array[Vector2i]
		for tile: Vector2i in frozenTiles:
			frozenTiles[tile] -= delta
			if frozenTiles[tile] <= 0:
				toUnfreezeFlat.append(tile)
				tilesRemove.append(tile)
		for tile: Vector2i in tilesRemove:
			frozenTiles.erase(tile)
		if not toUnfreezeFlat.is_empty():
			%LevelTiles.set_cells_terrain_connect(toUnfreezeFlat, TERRAIN_SET_WATER_ICE, TERRAIN_WATER, false)
	
	if not frozenStreamsX.is_empty():
		var toUnfreezeFalling: Array[Vector2i] = []
		var streamsRemove: Array[int]
		for stream: int in frozenStreamsX:
			frozenStreamsX[stream][0] -= delta
			if frozenStreamsX[stream][0] <= 0:
				toUnfreezeFalling.append_array(get_stream_tiles(stream, frozenStreamsX[stream]))
				streamsRemove.append(stream)
		for stream: int in streamsRemove:
			frozenStreamsX.erase(stream)
		if not toUnfreezeFalling.is_empty():
			%LevelTiles.set_cells_terrain_connect(toUnfreezeFalling, TERRAIN_SET_WATER_ICE, TERRAIN_FALLING_WATER, false)

# Currently missing functionality for resetting inventory and items
func _on_cat_reset_level() -> void:
	# If we end up adding different tile map layers, this will need to instead be a unique named one or passed in onready
	%LevelTiles.set_cells_terrain_connect(frozenTiles.keys(), TERRAIN_SET_WATER_ICE, TERRAIN_WATER, false)
	frozenTiles.clear()
	
	var frozenStreamTiles: Array[Vector2i] = []
	for stream: int in frozenStreamsX:
		frozenStreamTiles.append_array(get_stream_tiles(stream, frozenStreamsX[stream]))
	
	%LevelTiles.set_cells_terrain_connect(frozenStreamTiles, TERRAIN_SET_WATER_ICE, TERRAIN_FALLING_WATER, false)
	frozenStreamsX.clear()
	
	var i = 0
	for node: RigidBody2D in get_tree().get_nodes_in_group("pushable"):
		if not breakableStatus.keys().has(node) or not breakableStatus.get(node):
			node.reset(pushableStartPoints[i])
		i += 1

func _on_freezeTile_signal(flatWater: Array[Vector2i], flatIce: Array[Vector2i], fallingWater: Dictionary[int, Array], fallingIce: Array[int]) -> void:
	
	var layer: TileMapLayer = %LevelTiles
	var toFreezeFlat: Array[Vector2i] = []
	var toFreezeFalling: Array[Vector2i] = []
	
	for tile: Vector2i in flatIce:
		frozenTiles[tile] = 5
	for tile: Vector2i in flatWater:
		frozenTiles[tile] = 5
		toFreezeFlat.append(tile)
	
	for stream: int in fallingWater:
		toFreezeFalling.append_array(freeze_stream(stream, fallingWater[stream], layer))
	for stream: int in fallingIce:
		frozenStreamsX[stream][0] = 5
	
	layer.set_cells_terrain_connect(toFreezeFlat, TERRAIN_SET_WATER_ICE, TERRAIN_ICE, false)
	layer.set_cells_terrain_connect(toFreezeFalling, TERRAIN_SET_WATER_ICE, TERRAIN_FALLING_ICE, false)


func freeze_stream(x: int, yValues: Array, layer: TileMapLayer) -> Array[Vector2i]:
	
	var freezeTiles: Array[Vector2i] = []
	
	var lowestTile: Vector2i = Vector2i(x, yValues.max())
	var highestTile: Vector2i = lowestTile
	
	freezeTiles.push_back(lowestTile)
	
	# Iterates through any freezable tiles above the bottommost frozen tile and adds them to be frozen
	var aboveTile: Vector2i = layer.get_neighbor_cell(lowestTile, TileSet.CELL_NEIGHBOR_TOP_SIDE)
	while aboveTile and check_data(aboveTile, layer, "freezable"):
		freezeTiles.append(aboveTile)
		highestTile = aboveTile
		aboveTile = layer.get_neighbor_cell(aboveTile, TileSet.CELL_NEIGHBOR_TOP_SIDE)
	
	#Iterates through any falling water tiles 2 below the bottommost frozen tile and removes them
	var belowTile: Vector2i = layer.get_neighbor_cell(lowestTile, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
	if belowTile and check_data(belowTile, layer, "falling"):
		freezeTiles.push_back(belowTile)
		lowestTile = belowTile
	belowTile = layer.get_neighbor_cell(belowTile, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
	while belowTile and check_data(belowTile, layer, "falling"):
		layer.erase_cell(belowTile)
		lowestTile = belowTile
		belowTile = layer.get_neighbor_cell(belowTile, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
	
	frozenStreamsX[x] = [5, highestTile.y, lowestTile.y]
	
	return freezeTiles


func _on_next_level_placeholder_body_entered(_body: Node2D) -> void:
	get_tree().call_deferred("change_scene_to_packed", nextLevel)


func get_stream_tiles(x: int, stream: Array) -> Array[Vector2i]:
	var tiles: Array[Vector2i]
	
	for y: int in range(stream[1], stream[2]+1):
		tiles.append(Vector2i(x,y))
	
	return tiles

func check_data(tile: Vector2i, layer: TileMapLayer, attribute: String) -> Variant:
	var data: TileData = layer.get_cell_tile_data(tile)
	if data and data.has_custom_data(attribute):
		return data.get_custom_data(attribute)
	return null

var litUpTiles: Array[Vector2i] = []

func _on_cat_trigger_tiles(layer: TileMapLayer, tiles: Array[Vector2i] = []) -> void:
	if tiles.is_empty():
		for tile: Vector2i in litUpTiles:
			layer.remove_child(layer.get_child(0))
		litUpTiles.clear()
	else:
		var tileTriggers: Dictionary[String, Array] = {"plant": [], "scratchable": [], "entrance": []}
		for tile: Vector2i in tiles:
			var data = check_data(tile, layer, "Trigger")
			if data:
				tileTriggers.get(data).append(tile)
		if not tileTriggers.get("plant").is_empty() and cat.check_for_spell("Plant Spell"):
			for tile in tileTriggers.get("plant"):
				litUpTiles.push_back(add_light(layer, Color.GOLD, tile))
		for tile in tileTriggers.get("scratchable"):
			litUpTiles.push_back(add_light(layer, Color.MAGENTA, tile))
		for tile in tileTriggers.get("entrance"):
			litUpTiles.push_back(add_light(layer, Color.TOMATO, tile))

func add_light(layer: TileMapLayer, colour: Color, tile: Vector2i) -> Vector2: # Would replace this with something in tile map to do whole section rather than individual tiles, but works for now
	var light: ColorRect = ColorRect.new()
	light.color = Color(colour)
	light.set_size(Vector2(36,36))
	var pos: Vector2 = layer.to_global(layer.map_to_local(tile)) - Vector2(18, 18)
	light.set_global_position(pos)
	layer.add_child(light)
	return pos
