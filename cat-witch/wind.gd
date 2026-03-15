extends RigidBody2D

@export var force = Vector2(100, 0)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta):
	var collision = move_and_collide(force)
	if collision and collision.get_collider().is_in_group("Rigidbody"):
		collision.get_collider().apply_force(force * 50)

func _on_timer_timeout() -> void:
	queue_free()
