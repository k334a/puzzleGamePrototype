extends AnimatableBody2D

func unfurl() -> void:
	$AnimationPlayer.play("unfurl")

func furlup() -> void:
	$AnimationPlayer.play("furlup")

func reset() -> void:
	$AnimationPlayer.play("RESET")
