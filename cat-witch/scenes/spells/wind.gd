extends RigidBody2D

@export var force = Vector2(100, 0)

func _physics_process(_delta):
	var collision = move_and_collide(force)
	if collision and collision.get_collider().is_in_group("pushable"):
		collision.get_collider().apply_force(force * 50)

func _on_timer_timeout() -> void:
	queue_free()
