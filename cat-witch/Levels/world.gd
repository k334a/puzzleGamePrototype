extends Node

@export var zoom: Vector2 = Vector2(0.75, 0.75)

@onready var inventory_ui: InventoryUI = $InventoryUI
@onready var cat = $cat

var pushableStartPoints: Dictionary
var breakableStatus: Dictionary
var damagedAreas: Dictionary
var unlockedEntrances: Dictionary
var floatingItems: Dictionary

var frozenTiles: Dictionary[Vector2i, float] # { (x,y): time_left }
var frozenStreamsX: Dictionary[int, Array] # { x: [time_left, top_y, bottom_y] }
var buttonStreams: Dictionary[int, Array]

signal saveLevel
signal loadLevel

enum { TERRAIN_SET_FLOOR_WALL, TERRAIN_SET_WATER_ICE, TERRAIN_SET_SLOPED }
enum { TERRAIN_FLOOR, TERRAIN_CLIMBABLE, TERRAIN_DISAPPEAR, TERRAIN_ONE_WAY }
enum { TERRAIN_WATER, TERRAIN_FALLING_WATER, TERRAIN_ICE, TERRAIN_FALLING_ICE }
enum { TERRAIN_SLOPED_RIGHT, TERRAIN_SLOPED_LEFT }

func _ready() -> void:
	for pushable: RigidBody2D in get_tree().get_nodes_in_group("pushable"):
		pushableStartPoints.set(pushable, pushable.global_position)
	inventory_ui.update_vases(false, get_tree().get_node_count_in_group("breakable"))
	cat.set_camera(%CameraTopLeft.global_position.y, %CameraBottomRight.global_position.x, %CameraBottomRight.global_position.y, %CameraTopLeft.global_position.x, zoom)

func set_up_jars(jarSet: Dictionary) -> void:
	breakableStatus = jarSet.duplicate(true)
	for jar: RigidBody2D in get_tree().get_nodes_in_group("breakable"):
		if breakableStatus.has(jar.get_path()) and breakableStatus.get(jar.get_path()):
			jar.objectRemove()
			inventory_ui.update_vases(true)
		else:
			breakableStatus.set(jar.get_path(), false)
			jar.jar_broken.connect(_on_jar_broken)

func set_up_areas(damageSet: Dictionary, entranceSet: Dictionary, entrancesNew: Array) -> void:
	damagedAreas = damageSet
	unlockedEntrances = entranceSet
	for area: interactive_area in get_tree().get_nodes_in_group("interaction"):
		if damagedAreas.has(area.get_path()):
			if area.set_damage(damagedAreas.get(area.get_path())):
				continue
		area.areaHit.connect(_on_interaction_area_entered)
		area.areaLeft.connect(_on_interaction_area_exited)
		if area.gets_unlocked:
			if unlockedEntrances.has(area.get_path()) and unlockedEntrances.get(area.get_path()):
				area.unlock()
			elif entrancesNew.has(area.entranceFrom):
				unlockedEntrances.set(area.get_path(), true)
				area.unlock()

func set_up_items(itemSet: Dictionary) -> void:
	for item: Item in itemSet:
		var contained: SpellPickup = load("res://scenes/Inventory_and_Items/key_pickup.tscn").instantiate()
		contained.item = item
		add_child(contained)
		contained.global_position = itemSet[item]

func set_up_cat(spells: Array, items: Array, location: Vector2) -> void:
	cat.set_up_cat(spells, items, location)
	for pickup: SpellPickup in get_tree().get_nodes_in_group("pickup"):
		if cat.check_for_spell(pickup.item.name) or cat.check_for_item(pickup.item.itemIDName):
			pickup.queue_free()

func _on_jar_broken(jar: RigidBody2D, pos: Vector2) -> void:
	breakableStatus.set(jar.get_path(), true)
	inventory_ui.update_vases(true)
	if not inventory_ui.visible:
		inventory_ui.show_jars()
	if breakableStatus.values().all(func(jarStatus): return jarStatus):
		print("Broke all jars!")
	if jar.containedItem and jar.containedItem is Item:
		var contained: SpellPickup = load("res://scenes/Inventory_and_Items/key_pickup.tscn").instantiate()
		contained.item = jar.containedItem
		add_child(contained)
		contained.global_position = pos

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
	%LevelTiles.set_cells_terrain_connect(frozenTiles.keys(), TERRAIN_SET_WATER_ICE, TERRAIN_WATER, false)
	frozenTiles.clear()
	
	var frozenStreamTiles: Array[Vector2i] = []
	for stream: int in frozenStreamsX:
		frozenStreamTiles.append_array(get_stream_tiles(stream, frozenStreamsX[stream]))
	for stream: int in buttonStreams:
		frozenStreamTiles.append_array(get_stream_tiles(stream, buttonStreams[stream], -1))
	
	%LevelTiles.set_cells_terrain_connect(frozenStreamTiles, TERRAIN_SET_WATER_ICE, TERRAIN_FALLING_WATER, false)
	frozenStreamsX.clear()
	buttonStreams.clear()
	
	for node: RigidBody2D in get_tree().get_nodes_in_group("pushable"):
		if not breakableStatus.keys().has(node.get_path()) or not breakableStatus.get(node.get_path()):
			node.reset(pushableStartPoints.get(node))
	
	for node: RigidBody2D in get_tree().get_nodes_in_group("breakable"):
		if not breakableStatus.get(node.get_path()):
			node.reset()
	
	for node: AnimatableBody2D in get_tree().get_nodes_in_group("plant"):
		node.reset()
	for node: Node2D in get_tree().get_nodes_in_group("doors"):
		node.reset()
	for node: interactive_area in get_tree().get_nodes_in_group("interaction"):
		node.pressed = false

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

func _on_freeze_stream_signal(streamStop: Array[Vector2i], layer: TileMapLayer) -> void:
	var freezeTiles: Array[Vector2i] = []
	for stream: Vector2i in streamStop:
		freezeTiles.append(stream)
		var below: Vector2i = layer.get_neighbor_cell(stream, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
		var lowestTile: Vector2i = below
		while below and check_data(below, layer, "falling"):
			layer.erase_cell(below)
			lowestTile = below
			below = layer.get_neighbor_cell(below, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
		buttonStreams[stream.x] = [stream.y, lowestTile.y]
	layer.set_cells_terrain_connect(freezeTiles, TERRAIN_SET_WATER_ICE, TERRAIN_FALLING_ICE, false)

func _on_cat_unfreeze_stream(unfreezeTiles: Array, layer: TileMapLayer) -> void:
	var toUnfreeze: Array[Vector2i]
	for stream: int in unfreezeTiles:
		toUnfreeze.append_array(get_stream_tiles(stream, buttonStreams[stream], -1))
		buttonStreams.erase(stream)
	layer.set_cells_terrain_connect(toUnfreeze, TERRAIN_SET_WATER_ICE, TERRAIN_FALLING_WATER, false)

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

func get_stream_tiles(x: int, stream: Array, offset: int=0) -> Array[Vector2i]:
	var tiles: Array[Vector2i]
	
	for y: int in range(stream[1+offset], stream[2+offset]+1):
		tiles.append(Vector2i(x,y))
	
	return tiles

func check_data(tile: Vector2i, layer: TileMapLayer, attribute: String) -> Variant:
	var data: TileData = layer.get_cell_tile_data(tile)
	if data and data.has_custom_data(attribute):
		return data.get_custom_data(attribute)
	return null

func _on_interaction_area_entered(area: interactive_area) -> void:
	if area.instantEntrance and area.areaType == "Entrance":
		cat.instantEntrance(area)
		return
	
	if (not area.areaType == "Plant") or (cat.check_for_spell("Plant Spell")):
		area.light_on()
		cat.onTrigger = area

func _on_interaction_area_exited(area: interactive_area) -> void:
	area.light_off()
	cat.onTrigger = null

func _on_cat_unfurl_plant(area: interactive_area) -> void:
	area.plantNode.unfurl()

func _on_cat_next_level(levelName: String, location: Vector2, spells: Array, items: Array) -> void:
	save_world_values()
	saveLevel.emit(breakableStatus, damagedAreas, unlockedEntrances, floatingItems)
	for child: Node in get_children():
		child.set_physics_process(false)
		child.set_process(false)
	loadLevel.emit(levelName, location, spells, items)
	self.queue_free()

func save_world_values() -> void:
	for item: SpellPickup in get_tree().get_nodes_in_group("pickup"):
		if not item.item.isSpell:
			floatingItems.set(item.item, item.global_position)
	for area: interactive_area in get_tree().get_nodes_in_group("interaction"):
		if area.gets_unlocked and area.get_parent().itemUsed:
			unlockedEntrances.set(area.get_path(), true)

func _on_cat_record_scratch(triggered: interactive_area) -> void:
	damagedAreas.set(triggered.get_path(), triggered.get_parent().damage)

func _on_spell_select_update_inventory(spell_name: String, selected: bool) -> void:
	var spells = cat.inventory.spellsKnown
	if selected:
		for i in range(spells.size()):
			if spells[i].name == spell_name:
				cat.inventory.add_spell(spells[i])
				break
	else:
		cat.inventory.remove_spell(spell_name)

signal unlockEntrance

func _on_cat_unlock_entrance(destination: String) -> void:
	unlockEntrance.emit(destination)
