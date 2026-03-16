extends ProgressBar

func _physics_process(delta: float) -> void:
	value = %FreezeDuration.time_left
