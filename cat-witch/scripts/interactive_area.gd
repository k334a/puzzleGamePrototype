extends Area2D

class_name interactive_area

@export var areaType: String
@export var plantNode: AnimatableBody2D
@export var entranceLevel: PackedScene

signal areaHit
signal areaLeft

func light_on(colour: Color) -> void:
	var styleBox: StyleBoxFlat = $Panel.get_theme_stylebox("panel").duplicate()
	styleBox.set("border_color", colour)
	$Panel.add_theme_stylebox_override("panel", styleBox)
	$Panel.show()

func light_off() -> void:
	$Panel.hide()

func _on_body_entered(_body: Node2D) -> void:
	areaHit.emit(self)

func _on_body_exited(_body: Node2D) -> void:
	areaLeft.emit(self)
