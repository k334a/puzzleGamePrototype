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
var spellCooldowns = [0, 0, 0, 0]

#Inventory
@onready var inventory: Inventory = $Inventory

# For respawn:
@onready var startPosition: Vector2 = global_position

signal resetLevel
signal freezeTiles

func apply_outside_force(forceVector, outsideForce):
	velocity.x += forceVector.x * outsideForce
	velocity.y += forceVector.y * outsideForce

func _input(event):
	if(event.is_action_released("jump")):
		if (velocity.y < 0):
			velocity.y *= cutHeight


func linearDampener(left, right):
	var on_ice: bool = false
	if not left and not right:
		var body = %floor_ray.get_collider()
		if body and body is not RigidBody2D:
			var tile: Vector2i = body.local_to_map(body.to_local(%floor_ray.global_position))
			tile = tile - Vector2i(0, -1)
			var data = check_data(tile, body, "terrain_type")
			if data == "ice":
				on_ice = true
		if on_ice:
			velocity.x -= velocity.x * 0.01
		else:
			velocity.x -= velocity.x * 0.5

# Problem: We have decceleration but we do not have acceleration
func _physics_process(delta):
	var right = Input.is_action_pressed('move_right')
	var left = Input.is_action_pressed('move_left')
	var crouch = Input.is_action_pressed('crouch')
	var jump = Input.is_action_pressed('jump')
	#var run = Input.is_action_pressed('run')
	#var scratch = Input.is_action_just_pressed('scratch')
	var spell1 = Input.is_action_just_pressed('wind')
	var spell2 = Input.is_action_just_pressed('freeze')
	
	# Gravity Physics
	if not is_on_floor():
		if velocity.x > 0:
			velocity.x -= 350 * delta
		elif velocity.x < 0:
			velocity.x += 350 * delta
		if velocity.y < 0: # Moving UP
			$AnimatedSprite2D.play("jump")
		elif velocity.y > 0:              # Moving DOWN
			$AnimatedSprite2D.play("fall")
	else:
		if velocity.y == 0:
			$AnimatedSprite2D.play("idle")

	# Movement
	if right:
		if velocity.x < 350:
			velocity.x = run_speed
		if $AnimatedSprite2D.flip_h == true:
			$Pivot.scale.x = 1
			$AnimatedSprite2D.flip_h = false
	
	if left:
		if velocity.x > -350:
			velocity.x = -run_speed
		if $AnimatedSprite2D.flip_h == false:
			$Pivot.scale.x = -1
			$AnimatedSprite2D.flip_h = true
	
	linearDampener(left, right)
	
	#Wall Collision
	if wall_jump_lock > 0.0:
		wall_jump_lock -= delta
	if velocity.x:
		%wall_ray.target_position.x = 13.5 * sign(velocity.x)
	var on_wall: bool = %wall_ray.is_colliding() and TileMapCheck()
	var on_wall_in_air: bool = on_wall and !is_on_floor()
	
	# Wall Sliding
	if on_wall_in_air and velocity.y > 0:
		wall_contact_coyote = WALL_CONTACT_COYOTE_TIME
		look_dir_x = int(-%wall_ray.get_collision_normal().x)
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
	
	# Freeze checking
	if %FreezeBubble.visible and %FreezeBubble.has_overlapping_bodies():
		%FreezeBubble.freeze_check()
	
	# Spells
	if spell1:
		#if $Inventory.spells[0] and $Spell1Cooldown.is_stopped():
		if $Spell1Cooldown.is_stopped():
			readSpell(left, right, crouch, jump, 0)
			$Spell1Cooldown.wait_time = spellCooldowns[0]
			$Spell1Cooldown.start()
	if spell2:
		if $Spell2Cooldown.is_stopped():
			readSpell(left, right, crouch, jump, 1)
			$Spell2Cooldown.wait_time = spellCooldowns[1]
			$Spell2Cooldown.start()

	if crouch and is_on_floor():
		velocity.x = 0
		$AnimatedSprite2D.scale = Vector2(1.5, 0.5)
		print($AnimatedSprite2D.offset)
		$AnimatedSprite2D.offset.y = 50
	else:
		$AnimatedSprite2D.scale = Vector2(1, 1)
		$AnimatedSprite2D.offset.y = 0

	move_and_slide()

# Read Tilemap Helper
func TileMapCheck():
	var body = %wall_ray.get_collider()
	if body is TileMapLayer:
		var centerTile: Vector2i = body.local_to_map(body.to_local(%wall_ray.global_position)) #Gets a tile in local coordinates of TileMapLayer for center of bubble
		var tile: Vector2i = centerTile + Vector2i(int(-%wall_ray.get_collision_normal().x) * 2, 0)
		var data = check_data(tile, body, "climbable")
		if data:
			return true
	return false

# Spell Functions
func readSpell(left_input, right_input, down_input, up_input, index):
	if not $Inventory.spells[index]:
		return 		# Ends the function if there is no valid spell
		
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
	if not magnitude:
		lookVector = Vector2($Pivot.scale.x, 0)
	else:
		lookVector = Vector2(lookVector.x / magnitude, lookVector.y / magnitude)
	
	var spell_list = {
		0: func(): wind(lookVector); spellCooldowns[index] = 1,
		1: func(): freeze(); spellCooldowns[index] = 5,
	}
	
	var spell = $Inventory.spells[index].spell_type
	
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
	#print(lookVector)
	var wind_loc
	add_sibling(windScene)
	apply_outside_force(lookVector, outsideForce)
	
func _spell_cooldown_ended(index: int):
	spellCooldowns[index] = false
	
func _ready() -> void:
	%PickupArea.area_entered.connect(_on_pickup_area_entered)

#handler
func _on_pickup_area_entered(area: Area2D) -> void:
	if not area.is_in_group("pickup"):
		return
	
	var try_pickup = inventory.add_item(area.item)

	if try_pickup:
		if area.item.isSpell:
			inventory.add_spell(area.item)
		area.queue_free()

	else:
		print("Inventory full!")

# when spell is picked up, move it to the first spell slot. allow movement between slots

func resetCat() -> void:
	velocity = Vector2.ZERO
	%FreezeBubble.reset()
	global_position = startPosition
	resetLevel.emit()

# This is duplicated in freeze_bubble and world
func check_data(tile: Vector2i, layer: TileMapLayer, attribute: String) -> Variant:
	var data: TileData = layer.get_cell_tile_data(tile)
	if data and data.has_custom_data(attribute):
		return data.get_custom_data(attribute)
	return null

func _on_water_checker_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		if %FreezeBubble.visible: # If player manages to hit water while freeze is active because they were too fast, checks extra inner corners in bubble
			%FreezeBubble.freeze_check(true)
		else:
			resetCat()

func _on_freeze_bubble_freeze_tile(flatWater: Array[Vector2i], flatIce: Array[Vector2i], fallingWater: Dictionary[int, Array], fallingIce: Array[int]) -> void:
	freezeTiles.emit(flatWater, flatIce, fallingWater, fallingIce)
