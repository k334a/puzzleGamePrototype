extends "res://Levels/world.gd"

func _process(_delta: float) -> void:
	#For debug
	var reset = Input.is_action_pressed('Reset')
	if reset:
		teleport(Vector2(6, -37))
	
	if Input.is_action_just_pressed("inventory"):
		inventory_ui.toggle(cat.inventory)

func teleport(target_pos: Vector2):
	# 1. Update the Physics Server directly
	var transform_2d = Transform2D(0, target_pos) # 0 is rotation
	PhysicsServer2D.body_set_state(
		$TestShape.get_rid(), 
		PhysicsServer2D.BODY_STATE_TRANSFORM, 
		transform_2d
	)
	
	# 2. Reset momentum so it doesn't "fly" away from the new spot
	$TestShape.linear_velocity = Vector2.ZERO
	$TestShape.angular_velocity = 0.0
