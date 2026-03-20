extends Area2D

func startFreeze() -> void:
	if %FreezeCooldown.is_stopped() and %FreezeDuration.is_stopped():
		show()
		%FreezeDuration.start()

func reset() -> void:
	hide()
	%FreezeCooldown.stop()
	%FreezeDuration.stop()


func _on_freeze_duration_timeout() -> void:
	hide()
	%FreezeCooldown.start()
