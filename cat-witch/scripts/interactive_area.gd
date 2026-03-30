extends Area2D

class_name interactive_area

var areaType: String
var scratchable: bool
var entranceLevel: String
var plantNode: AnimatableBody2D
var item: Item

signal areaHit
signal areaLeft
signal damageSelf

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
	damageSelf.emit()

func set_up(interactionType: String, scratchToReveal: bool, entrance: String, plant: AnimatableBody2D, lightUpArea: Dictionary[String, int]={}, itemObject: Item=null, collisionArea: Dictionary[String, int]={}) -> void:
	scratchable = ((not interactionType == "Entrance") or scratchToReveal)
	areaType = interactionType
	match interactionType:
		"Entrance":
			if scratchable:
				areaType = "Scratch"
			entranceLevel = entrance
		"Plant":
			plantNode = plant
		"":
			areaType = "Scratch"
			if itemObject:
				item = itemObject
	
	if not collisionArea.is_empty():
		$CollisionShape2D.apply_scale(Vector2(collisionArea["width"], collisionArea["height"]))
		$CollisionShape2D.position = Vector2(collisionArea["x"], collisionArea["y"])
	if not lightUpArea.is_empty():
		$Panel.scale = Vector2(lightUpArea["width"], lightUpArea["height"])
		$Panel.position = Vector2(lightUpArea["x"], lightUpArea["y"])
