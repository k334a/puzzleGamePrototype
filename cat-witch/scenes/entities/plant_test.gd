extends AnimatableBody2D

var damage: int = 0
@export var plantHealth: int = 1
@export var damageFrameOffset: int = 1

func _ready() -> void:
	$InteractiveArea.set_up("Plant", false, "", self)

func unfurl() -> void:
	if damage == 0:
		$AnimationPlayer.play("plant_test_animation/unfurl")
	else:
		$AnimationPlayer.play("plant_test_animation/unfurl_damage_" + String.num(damage))
	$InteractiveArea.areaType = "Scratch"

func furlup() -> void:
	if damage == 0:
		$AnimationPlayer.play("plant_test_animation/furlup")
	else:
		$AnimationPlayer.play("plant_test_animation/furlup_damage_" + String.num(damage))
	$InteractiveArea.areaType = "Plant"

func reset() -> void:
	show()
	$CollisionPolygon2D.disabled = false
	$AnimationPlayer.play("plant_test_animation/RESET")
	damage = 0
	$InteractiveArea.areaType = "Plant"

func _on_interactive_area_damage_self() -> void:
	damage += 1
	if damage == plantHealth:
		$InteractiveArea.light_off()
		$CollisionPolygon2D.disabled = true
		$InteractiveArea.monitoring = false
		hide()
	else:
		$AnimatedSprite2D.frame += damageFrameOffset
