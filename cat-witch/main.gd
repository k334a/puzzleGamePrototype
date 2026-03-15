extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#For debug
	var reset = Input.is_action_pressed('Reset')
	if reset:
		teleport(Vector2(6, -37))

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
