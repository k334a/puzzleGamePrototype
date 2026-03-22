extends ProgressBar

func _physics_process(_delta: float) -> void:
	value = %FreezeDuration.time_left
