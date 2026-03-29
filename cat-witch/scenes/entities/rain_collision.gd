extends Area2D

var lightningObject = load("res://scenes/entities/lightning.tscn")
var lightning
var lightning_on = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.wet = true
		get_parent().cat = body
		if lightning_on:
			lightning = lightningObject.instantiate()
			lightning.local_rain = self
			lightning.local_body = body
			add_sibling(lightning)
			$LightningTimer.start()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.wet = false
		if lightning_on:
			if lightning:
				lightning.queue_free()
			$LightningTimer.stop()
			$LightningTimer.set_wait_time(5)
