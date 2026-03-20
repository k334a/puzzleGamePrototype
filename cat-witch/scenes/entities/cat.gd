extends CharacterBody2D

#Physics Variables
var run_speed = 350
var jump_speed = -1000
var gravity = 1500
var windResistance = 1500
var cutHeight = 0.5
var airtime = false
#var outsideForce = 0

#Push Extras
const PUSH_FORCE = 100
const MAX_VELOCITY = 150

#Climb Extras
var wall_contact_coyote: float = 0.0
const WALL_CONTACT_COYOTE_TIME: float = 0.2
var look_dir_x: int = 1
var CLIMB_SPEED: float = 150
var CLIMB_EXIT_BOOST: Vector2 = Vector2(100, -100)
var is_climbing: bool = false
const WALL_JUMP_PUSH_FORCE: float = 400
var wall_jump_lock: float = 0.0

#Spell Variables
var windObject = load("res://scenes/spells/wind.tscn")

#Inventory
@onready var inventory: Inventory = $Inventory

# For respawn and freezing:
@onready var startPosition: Vector2 = global_position
@onready var freezeRadius: int = ceil(float($FreezeBubble/CollisionShape2D.shape.radius) / 36.0) #36 is size of tiles, should be edited later

signal resetLevel
signal freezeTile

func apply_outside_force(forceVector, outsideForce):
	velocity.x += forceVector.x * outsideForce
	velocity.y += forceVector.y * outsideForce

func _input(event):
	if(event.is_action_released("jump")):
		if (velocity.y < 0):
			velocity.y *= cutHeight

# Problem: We have decceleration but we do not have acceleration
func _physics_process(delta):
	#var forceVector = Vector2.ZERO
	var right = Input.is_action_pressed('move_right')
	var left = Input.is_action_pressed('move_left')
	var crouch = Input.is_action_pressed('crouch')
	var jump = Input.is_action_pressed('jump')
	#var run = Input.is_action_pressed('run')
	#var scratch = Input.is_action_just_pressed('scratch')
	var spell1 = Input.is_action_just_pressed('wind')
	var spell2 = Input.is_action_just_pressed('freeze')
	
	# Gravity Physics
	if not is_on_floor() and velocity.x > 0:
			velocity.x -= 350 * delta
	elif not is_on_floor() and velocity.x < 0:
			velocity.x += 350 * delta
		#velocity.x -= velocity.x * 0.1
	else:
		velocity.x -= velocity.x * 0.5
		
	# Movement
	if right and velocity.x < 350:
		velocity.x = run_speed
	
	if left and velocity.x > -350:
		velocity.x = -run_speed
	
	#Wall Collision
	if wall_jump_lock > 0.0:
		wall_jump_lock -= delta
	if velocity.x:
		$wall_ray.target_position.x = 13.5 * sign(velocity.x)
	var on_wall: bool = $wall_ray.is_colliding() and $wall_ray.get_collider().name == "climbable"
	var on_wall_in_air: bool = on_wall and !is_on_floor()
	
	# Wall Sliding
	if on_wall_in_air and velocity.y > 0:
		wall_contact_coyote = WALL_CONTACT_COYOTE_TIME
		look_dir_x = int(-$wall_ray.get_collision_normal().x)
	else:
		if wall_contact_coyote > 0.0:
			wall_contact_coyote -= delta
		velocity.y += gravity * delta

	# Jumping
	if (is_on_floor() or wall_contact_coyote > 0.0) and jump:
		velocity.y = jump_speed
		airtime = true
		if wall_contact_coyote > 0.0 and !is_on_floor():
			velocity.x = -look_dir_x * WALL_JUMP_PUSH_FORCE
			wall_jump_lock = 0.5
	
	# Push Physics
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collision_crate = collision.get_collider()
		if collision_crate.is_in_group("pushable") and abs(collision_crate.get_linear_velocity().x) < MAX_VELOCITY:
			collision_crate.apply_central_impulse(collision.get_normal() * -PUSH_FORCE)
	
	# Freeze checking (checking within physics process since delays were making it so that you could hit water before it froze)
	if %FreezeBubble.visible and %FreezeBubble.has_overlapping_bodies() and %FreezeBubble.get_overlapping_bodies().front() is TileMapLayer: # last check should be redundant
		freeze_check(%FreezeBubble.get_overlapping_bodies().front())
	
	# Spells
	if spell1:
		readSpell(left, right, crouch, jump, "wind")
	
	if spell2:
		readSpell(left, right, crouch, jump, "freeze")
	
	move_and_slide()

# Spell Functions
func readSpell(left_input, right_input, down_input, up_input, spell):
	# Compute current key presses into vector
	var lookVector = Vector2.ZERO
	if left_input:
		lookVector.x -= 1
	if right_input:
		lookVector.x += 1
	if down_input:
		lookVector.y += 1
	if up_input:
		lookVector.y -= 1
	var magnitude = abs(lookVector.x) + abs(lookVector.y)
	if magnitude == 0:
		lookVector  = Vector2(1,0)
	else:
		lookVector = Vector2(lookVector.x / magnitude, lookVector.y / magnitude)
	
	var spell_list = {
		"freeze": func(): freeze(),
		"wind": func(): wind(lookVector),
	}
	spell_list[spell].call()

func freeze():
	%FreezeBubble.startFreeze()

func wind(lookVector):
	velocity.x = 0
	velocity.y = 0
	var outsideForce = 1500
	var windScene = windObject.instantiate()
	windScene.position = Vector2(position.x, position.y - 50)
	windScene.get_child(0).force = -lookVector * 100
	add_sibling(windScene)
	apply_outside_force(lookVector, outsideForce)

func _ready() -> void:
	$PickupArea.area_entered.connect(_on_pickup_area_entered)

#handler
func _on_pickup_area_entered(area: Area2D) -> void:
	if not area.is_in_group("pickup"):
		return
	
	var try_pickup = inventory.add_item(area.item)

	if try_pickup:
		area.queue_free()
	else:
		print("Inventory full!")

func resetCat() -> void:
	velocity = Vector2.ZERO
	%FreezeBubble.reset()
	global_position = startPosition
	resetLevel.emit()
	

# Will clean this up later
func freeze_check(layer: TileMapLayer) -> void:
	
	# Gets a tile in local coordinates of TileMapLayer for center of bubble
	var centerTile: Vector2i = layer.local_to_map(layer.to_local(%FreezeBubble.global_position))
	
	var freezableTiles: Array[Vector2i] = []
	var fallingTiles: Dictionary[int, Array] = {}
	var tiles: Array[Vector2i]
	var corners: Array[int] # Only necessary if the bubble size changes, current radius doesn't cause corners
	
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
	
	# Checks each tile for if it is water or falling water
	for tile in tiles:
		if check_data(tile, layer, "fallingWater"):
			# Falling water tiles are added to dictionary with x as key and y as value
			fallingTiles.get_or_add(tile.x, []).push_back(tile.y)
		elif check_data(tile, layer, "freezable"): # Falling water tiles should not be added to freezableTiles
			freezableTiles.push_back(tile)
	if not freezableTiles.is_empty() or not fallingTiles.is_empty(): # This check should be redundant
		freezeTile.emit(freezableTiles, fallingTiles, layer)

func check_data(tile: Vector2i, layer: TileMapLayer, attribute: String) -> Variant:
	var data: TileData = layer.get_cell_tile_data(tile)
	if data and data.has_custom_data(attribute):
		return data.get_custom_data(attribute)
	return null

func _on_water_checker_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		resetCat()
