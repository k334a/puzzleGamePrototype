extends RigidBody2D

@export var max_speed = 1200

func teleport(target_pos: Vector2):
	# 1. Update the Physics Server directly
	var transform_2d = Transform2D(0, target_pos) # 0 is rotation
	PhysicsServer2D.body_set_state(
		get_rid(), 
		PhysicsServer2D.BODY_STATE_TRANSFORM, 
		transform_2d
	)
	
	# 2. Reset momentum so it doesn't "fly" away from the new spot
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0

func _integrate_forces(state: PhysicsDirectBodyState2D):
	var velocity = state.linear_velocity
	
	if velocity.length() > max_speed:
		state.linear_velocity = velocity.normalized()
		
	if state.linear_velocity.y < -max_speed:
		state.linear_velocity.y = -max_speed

func _physics_process(delta: float) -> void:
	var found_slope = false
	var target_angle = 0
	
	var state = PhysicsServer2D.body_get_direct_state(get_rid())
	for i in state.get_contact_count():
		var normal = state.get_contact_local_normal(i)
		if abs(normal.x) > 0.01 and abs(normal.x) < 1:
			target_angle = atan2(normal.x, -normal.y)
			found_slope = true
			break
		else:
			found_slope = false
		
		if not found_slope:
			target_angle = 0
	
	$Sprite2D.rotation = lerp_angle($Sprite2D.rotation, target_angle, 1)
	$Sprite2D2.rotation = lerp_angle($Sprite2D.rotation, target_angle, 1)
	$Sprite2D3.rotation = lerp_angle($Sprite2D.rotation, target_angle, 1)
