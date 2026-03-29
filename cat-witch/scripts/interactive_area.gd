extends Area2D

class_name interactive_area

@export var areaType: String
# Number of scratches it takes to reveal entrance, destroy plant, and destroy blocks
@export var scratchType: Dictionary[String, int] = { "entrance": -1, "plant": -1, "reveal": -1, "item": -1 }
@export var entranceLevel: PackedScene
@export var plantNode: AnimatableBody2D
@export var item: Item

signal areaHit
signal areaLeft
signal damageSelf
signal destroyed

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

func scratch() -> void:
	for type in scratchType:
		if scratchType[type] > -1:
			scratchType[type] -= 1
			damageSelf.emit()
			if scratchType[type] == 0:
				if type == "entrance":
					areaType = type
				else:
					areaType = ""
				destroyed.emit()
