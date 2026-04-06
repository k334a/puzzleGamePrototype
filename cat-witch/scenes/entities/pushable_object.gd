extends RigidBody2D

@onready var startPos: Vector2 = global_position

func reset(target_pos: Vector2):
	# 2. Reset momentum so it doesn't "fly" away from the new spot
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	# 1. Update the Physics Server directly
	var transform_2d = Transform2D(0, target_pos) # 0 is rotation
	PhysicsServer2D.body_set_state(
		get_rid(), 
		PhysicsServer2D.BODY_STATE_TRANSFORM, 
		transform_2d
	)

func _physics_process(_delta: float) -> void:
	if abs(global_position.x) > 10000 or abs(global_position.y) > 10000:
		print("resetting")
		reset(startPos)
