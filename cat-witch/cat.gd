extends CharacterBody2D

var run_speed = 350
var jump_speed = -1000
var gravity = 1500

#Extras
var cutHeight = 0.5
var jumpHeld = false

func get_input():
	velocity.x = 0
	var right = Input.is_action_pressed('move_right')
	var left = Input.is_action_pressed('move_left')
	var jump = Input.is_action_pressed('jump')

	if is_on_floor() and jump:
		velocity.y = jump_speed
	if right:
		velocity.x += run_speed
	if left:
		velocity.x -= run_speed

func _input(event):
	if(event.is_action_released("jump")):
		if (velocity.y < 0):
			velocity.y *= cutHeight
		#jumpHeld = false

func _physics_process(delta):
	velocity.y += gravity * delta
	get_input()
	move_and_slide()
