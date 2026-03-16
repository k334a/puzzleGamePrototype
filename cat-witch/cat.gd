extends CharacterBody2D

var run_speed = 350
var jump_speed = -1000
var gravity = 1500
var windResistance = 1500

#Extras
var cutHeight = 0.5
var airtime = false
var outsideForce = 0
var windObject = load("res://wind.tscn")

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

# For respawn and freezing:
@onready var startPosition: Vector2 = global_position
@onready var freezeReach: int = ceil(float($FreezeBubble/CollisionShape2D.shape.radius) / 36.0) #36 is size of tiles, should be edited later

func get_input():
	var forceVector = Vector2.ZERO
	var right = Input.is_action_pressed('move_right')
	var left = Input.is_action_pressed('move_left')
	var crouch = Input.is_action_pressed('crouch')
	var jump = Input.is_action_pressed('jump')
	var run = Input.is_action_pressed('run')
	var scratch = Input.is_action_just_pressed('scratch')
	var wind = Input.is_action_just_pressed('wind')
	var freeze = Input.is_action_just_pressed("freeze")

	if airtime and is_on_floor():
		airtime = false
		velocity.x = 0

	#if is_on_floor() and jump:
		#velocity.y = jump_speed
		#airtime = true
		
	if right and velocity.x < 350:
		velocity.x = run_speed
	
	if left and velocity.x > -350:
		velocity.x = -run_speed
	
	#Hacky way of doing it
	if scratch:
		$Area2D/claw_vfx.visible = true
	else:
		$Area2D/claw_vfx.visible = false
		
	if wind:
		velocity.x = 0
		velocity.y = 0
		outsideForce = 1500
		var mousePosition = get_global_mouse_position()
		var distanceX = mousePosition.x - position.x
		var distanceY = mousePosition.y - position.y
		#var magnitude = sqrt(pow(distanceX, 2) + pow(distanceY, 2))
		var magnitude = abs(distanceX) + abs(distanceY)
		forceVector = Vector2(distanceX / magnitude, distanceY / magnitude)
		print(forceVector)
		var windScene = windObject.instantiate()
		windScene.position = Vector2(position.x, position.y - 50)
		windScene.get_child(0).force = -forceVector * 100
		add_sibling(windScene)
		apply_outside_force(forceVector, outsideForce)
		
	#Hacky way of doing it
	if is_on_floor() and crouch:
		$AnimatedSprite2D.scale = Vector2(1.5, 0.5)
		velocity.x = 0
		velocity.y = 0
	else:
		$AnimatedSprite2D.scale = Vector2(1, 1)
	
	if freeze:
		%FreezeBubble.startFreeze()

func apply_outside_force(forceVector, outsideForce):
	velocity.x += forceVector.x * outsideForce
	velocity.y += forceVector.y * outsideForce

func _input(event):
	if(event.is_action_released("jump")):
		if (velocity.y < 0):
			velocity.y *= cutHeight

# Problem: We have decceleration but we do not have acceleration
func _physics_process(delta):
	
	# Gravity Physics
	if not is_on_floor() and velocity.x > 0:
			velocity.x -= 350 * delta
	elif not is_on_floor() and velocity.x < 0:
			velocity.x += 350 * delta
		#velocity.x -= velocity.x * 0.1
	else:
		velocity.x -= velocity.x * 0.5
	get_input()
	
	#Wall Physics
	if wall_jump_lock > 0.0:
		wall_jump_lock -= delta
	if velocity.x:
		$wall_ray.target_position.x = 13.5 * sign(velocity.x)
	var on_wall: bool = $wall_ray.is_colliding() and $wall_ray.get_collider().name == "climbable"
	var on_wall_in_air: bool = on_wall and !is_on_floor()
	
	if on_wall_in_air and velocity.y > 0:
		wall_contact_coyote = WALL_CONTACT_COYOTE_TIME
		look_dir_x = int(-$wall_ray.get_collision_normal().x)
	else:
		if wall_contact_coyote > 0.0:
			wall_contact_coyote -= delta
		velocity.y += gravity * delta

	if (is_on_floor() or wall_contact_coyote > 0.0) and Input.is_action_pressed('jump'):
		velocity.y = jump_speed
		airtime = true
		if wall_contact_coyote > 0.0 and !is_on_floor():
			velocity.x = -look_dir_x * WALL_JUMP_PUSH_FORCE
			wall_jump_lock = 0.5
	
	# Depends on how we want it
	if on_wall:
		velocity.y = 0
	
	# Push Physics
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collision_crate = collision.get_collider()
		if collision_crate.is_in_group("Rigidbody") and abs(collision_crate.get_linear_velocity().x) < MAX_VELOCITY:
			collision_crate.apply_central_impulse(collision.get_normal() * -PUSH_FORCE)

	move_and_slide()

func resetCat() -> void:
	velocity = Vector2.ZERO
	%FreezeBubble.reset()
	global_position = startPosition

# This is very inefficient and should instead be using the body_rid to find the specific tile that overlaps, will update later
func _on_freeze_bubble_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if %FreezeBubble.visible and body is TileMapLayer:
		var centerTile: Vector2i = body.local_to_map(body.to_local(%FreezeBubble.global_position)) #Gets a tile in local coordinates of TileMapLayer for center of bubble
		for x in range(-freezeReach, freezeReach+1):
			for y in range(-freezeReach, freezeReach+1):
				var tile = centerTile + Vector2i(x,y)
				if body.get_cell_tile_data(tile):
					if body.get_cell_tile_data(tile).get_custom_data("freezable"):
						body.set_cell(tile, 0, body.get_cell_atlas_coords(tile) + Vector2i(4, 0), 0)

func _on_water_checker_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body is TileMapLayer:
		resetCat()
