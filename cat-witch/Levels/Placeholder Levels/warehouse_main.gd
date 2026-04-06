extends "res://Levels/world.gd"


func _on_pressure_plate_weight_hit() -> void:
	$AnimatedSprite2D.frame += 1
