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
const PUSH_FORCE = 100
const MAX_VELOCITY = 150

func get_input():
	var forceVector = Vector2.ZERO
	var right = Input.is_action_pressed('move_right')
	var left = Input.is_action_pressed('move_left')
	var crouch = Input.is_action_pressed('crouch')
	var jump = Input.is_action_pressed('jump')
	var run = Input.is_action_pressed('run')
	var scratch = Input.is_action_just_pressed('scratch')
	var wind = Input.is_action_just_pressed('wind')

	if airtime and is_on_floor():
		airtime = false
		velocity.x = 0

	if is_on_floor() and jump:
		velocity.y = jump_speed
		airtime = true
		
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

func apply_outside_force(forceVector, outsideForce):
	velocity.x += forceVector.x * outsideForce
	velocity.y += forceVector.y * outsideForce

func _input(event):
	if(event.is_action_released("jump")):
		if (velocity.y < 0):
			velocity.y *= cutHeight

# Problem: We have decceleration but we do not have acceleration
func _physics_process(delta):
	velocity.y += gravity * delta
	if not is_on_floor() and velocity.x > 0:
			velocity.x -= 350 * delta
	elif not is_on_floor() and velocity.x < 0:
			velocity.x += 350 * delta
		#velocity.x -= velocity.x * 0.1
	else:
		velocity.x -= velocity.x * 0.5
	get_input()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collision_crate = collision.get_collider()
		if collision_crate.is_in_group("Rigidbody") and abs(collision_crate.get_linear_velocity().x) < MAX_VELOCITY:
			collision_crate.apply_central_impulse(collision.get_normal() * -PUSH_FORCE)

	move_and_slide()
