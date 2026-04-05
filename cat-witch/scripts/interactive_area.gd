extends Area2D

class_name interactive_area

var areaType: String
var scratchable: bool
var instantEntrance: bool
var entranceLevel: String
var entranceLocation: Vector2
var plantNode: AnimatableBody2D
var item: Item
var requiredItem: String

signal areaHit
signal areaLeft
signal damageSelf
signal clicked
signal itemUsed

func light_on() -> void:
	$RichTextLabel.show()

func light_off() -> void:
	$RichTextLabel.hide()

func _on_body_entered(_body: Node2D) -> void:
	areaHit.emit(self)

func _on_body_exited(_body: Node2D) -> void:
	areaLeft.emit(self)

func scratch() -> void:
	damageSelf.emit()

func set_up(interactionType: String, textOffset: Vector2=Vector2.ZERO, textBoxScale: Vector2=Vector2.ZERO, collisionScale: Vector2=Vector2.ONE, collisionOffset: Vector2=Vector2.ZERO) -> void:
	areaType = interactionType
	$RichTextLabel.global_position += textOffset
	if textBoxScale != Vector2.ZERO:
		$RichTextLabel.custom_minimum_size = textBoxScale
	$CollisionShape2D.apply_scale(collisionScale)
	$CollisionShape2D.position = collisionOffset
	if interactionType == "Button":
		$RichTextLabel.text = "[wave amp=10 freq=5]Click"

func set_up_itemUse(itemName: String) -> void:
	requiredItem = itemName

func set_up_scratchable(itemObject: Item=null) -> void:
	areaType = "Scratch"
	scratchable = true
	item = itemObject
	$RichTextLabel.text = "[wave amp=10 freq=5]Scratch"

func set_up_entrance(entrance: String, instant: bool, location: Vector2) -> void:
	entranceLevel = entrance
	entranceLocation = location
	instantEntrance = instant
	$RichTextLabel.text = "[wave amp=10 freq=5]Enter"

func set_up_plant(plant: AnimatableBody2D) -> void:
	plantNode = plant
	$RichTextLabel.text = "[wave amp=10 freq=5]Plant"

func click() -> void:
	clicked.emit()

func useItem() -> void:
	itemUsed.emit()
