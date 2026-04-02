extends Area2D

var player_in

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if player_in:
		if player_in.is_on_floor():
				var parent = get_parent()
				parent.get_node("AudioStreamPlayer").play()
				parent.get_node("StaticBody2D").queue_free()
				parent.get_node("StaticBody2D2").show()
				self.queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body:
		if body.is_in_group("player"):
			player_in = body

func _on_body_exited(_body: Node2D) -> void:
	player_in = null
