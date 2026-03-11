extends CharacterBody2D

var run_speed = 350
var jump_speed = -1000
var gravity = 1500
var windResistance = 1500

#Extras
var cutHeight = 0.5
var airtime = false
var outsideForce = 0

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
		velocity.x += run_speed
	
	if left and velocity.x > -350:
		velocity.x -= run_speed
	
	#Hacky way of doing it
	if is_on_floor() and crouch:
		$AnimatedSprite2D.scale = Vector2(1.5, 0.5)
		velocity.x = 0
	else:
		$AnimatedSprite2D.scale = Vector2(1, 1)
	
	#Hacky way of doing it
	if scratch:
		$claw_vfx.visible = true
	else:
		$claw_vfx.visible = false
		
	if wind:
		velocity.x = 0
		velocity.y = 0
		outsideForce = 1500
		forceVector = Vector2(0.5, -0.5)
		apply_outside_force(forceVector, outsideForce)

func apply_outside_force(forceVector, outsideForce):
	velocity.x += forceVector.x * outsideForce
	velocity.y += forceVector.y * outsideForce
func _input(event):
	if(event.is_action_released("jump")):
		if (velocity.y < 0):
			velocity.y *= cutHeight
		#jumpHeld = false

func _physics_process(delta):
	velocity.y += gravity * delta
	#if not is_on_floor():
	if not is_on_floor() and velocity.x > 0:
		velocity.x -= 350 * delta
	elif not is_on_floor() and velocity.x < 0:
		velocity.x += 350 * delta
		#velocity.x -= velocity.x * 0.1
	else:
		velocity.x -= velocity.x * 0.5
	get_input()
	move_and_slide()
