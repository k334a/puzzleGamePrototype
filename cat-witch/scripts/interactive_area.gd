extends Area2D

class_name interactive_area

@export var areaType: String
# Number of scratches it takes to reveal entrance, destroy plant, and destroy blocks
@export var scratchType: Dictionary[String, int] = { "entrance": -1, "plant": -1, "reveal": -1 }
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
		print(scratchType[type])
	if scratchType.entrance > 0:
		scratchType.entrance -= 1
		damageSelf.emit()
	if scratchType.entrance == 0: # Last one, entrance should be revealed now
		destroyed.emit()
		areaType = "entrance"
	if scratchType.plant > 0:
		scratchType.plant -= 1
		damageSelf.emit()
	if scratchType.plant == 0: # Last one, plant should disappear now
		areaType = ""
	if scratchType.reveal > 0:
		scratchType.reveal -= 1
		damageSelf.emit()
	if scratchType.reveal == 0:
		areaType = ""
