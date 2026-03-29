extends Area2D

var lightningObject = load("res://scenes/entities/lightning.tscn")
var lightning

func _on_body_entered(body: Node2D) -> void:
	if body.name == "cat":
		body.wet = true
		get_parent().cat = body
		lightning = lightningObject.instantiate()
		lightning.local_rain = self
		lightning.local_body = body
		add_sibling(lightning)
		$LightningTimer.start()

func _on_body_exited(body: Node2D) -> void:
	if body.name == "cat":
		body.wet = false
		if lightning:
			lightning.queue_free()
		$LightningTimer.stop()
		$LightningTimer.set_wait_time(5)
