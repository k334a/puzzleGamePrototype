extends CharacterBody2D

#Physics Variables
var run_speed = 350
var jump_speed = -1000
var gravity = 1500
var windResistance = 1500
var cutHeight = 0.5
var airtime = false
var outsideForce = 0

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
@onready var freezeReach: int = ceil(float($FreezeBubble/CollisionShape2D.shape.radius) / 36.0) #36 is size of tiles, should be edited later

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
	var forceVector = Vector2.ZERO
	var right = Input.is_action_pressed('move_right')
	var left = Input.is_action_pressed('move_left')
	var crouch = Input.is_action_pressed('crouch')
	var jump = Input.is_action_pressed('jump')
	var run = Input.is_action_pressed('run')
	var scratch = Input.is_action_just_pressed('scratch')
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
		if collision_crate.is_in_group("Rigidbody") and abs(collision_crate.get_linear_velocity().x) < MAX_VELOCITY:
			collision_crate.apply_central_impulse(collision.get_normal() * -PUSH_FORCE)
	
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
	outsideForce = 1500
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
	

# This is very inefficient and should instead be finding the specific tile that overlaps and using that, will look at better method later
func _on_freeze_bubble_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if %FreezeBubble.visible and body is TileMapLayer:
		var centerTile: Vector2i = body.local_to_map(body.to_local(%FreezeBubble.global_position)) #Gets a tile in local coordinates of TileMapLayer for center of bubble
		for x in range(-freezeReach, freezeReach+1):
			for y in range(-freezeReach, freezeReach+1):
				var tile = centerTile + Vector2i(x,y)
				if body.get_cell_tile_data(tile):
					if body.get_cell_tile_data(tile).get_custom_data("freezable"):
						freezeTile.emit(tile)
						body.set_cell(tile, 0, body.get_cell_atlas_coords(tile) + Vector2i(4, 0), 0) # Right now offset in the atlas is hardcoded as 4 away horizontally, not sure if this can be alternative tile instead?

func _on_water_checker_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body is TileMapLayer:
		resetCat()
