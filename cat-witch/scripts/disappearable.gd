extends Area2D

var player_in

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_in:
		if player_in.is_on_floor():
			self.queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body:
		if body.is_in_group("player"):
			player_in = body

func _on_body_exited(_body: Node2D) -> void:
	player_in = null
