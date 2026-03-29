extends AnimatableBody2D

var damage: int = 0

func unfurl() -> void:
	match damage:
		0:
			$AnimationPlayer.play("unfurl")
		1:
			$AnimationPlayer.play("unfurl_damage_1")
		2:
			$AnimationPlayer.play("unfurl_damage_2")
	$InteractiveArea.areaType = "scratch"

func furlup() -> void:
	match damage:
		0:
			$AnimationPlayer.play("furlup")
		1:
			$AnimationPlayer.play("furlup_damage_1")
		2:
			$AnimationPlayer.play("furlup_damage_2")
	$InteractiveArea.areaType = "plant"

func reset() -> void:
	$AnimatedSprite2D.show()
	$CollisionPolygon2D.disabled = false
	$AnimationPlayer.play("RESET")
	$InteractiveArea.areaType = "plant"
	$InteractiveArea.scratchType.plant = 2
	damage = 0


func _on_interactive_area_damage_self() -> void:
	damage += 1
	$AnimatedSprite2D.frame += 12

func _on_interactive_area_destroyed() -> void:
	$AnimatedSprite2D.hide()
	$CollisionPolygon2D.disabled = true
