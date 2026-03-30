extends AnimatedSprite2D

@export_enum("Scratch", "Entrance", "Plant") var interactionType: String
@export_group("Entrance")
@export var entrance: String
@export var scratchToReveal: bool
@export var entranceColour: Color
@export_group("Plant")
@export var plant: AnimatableBody2D
@export var plantColour: Color
@export_group("Scratch")
@export_enum("Entrance", "Plant", "Reveal", "Item") var scratchType: String
@export_range(0, 5, 1, "or_greater") var scratchValue: int
@export var item: Item
@export var scratchColour: Color
@export_category("")
@export var lightUpArea: Dictionary[String, int] = { "width": 1, "height": 1, "x": 0, "y": 0}
@export var collisionArea: Dictionary[String, int] = { "width": 1, "height": 1, "x": 0, "y": 0}
var damage: int = 0

signal damage_self
signal destroyed

func _ready() -> void:
	if not interactionType:
		push_error("Interaction type of interactive area not set: " + self.to_string())
	$InteractiveArea.set_up(interactionType, scratchToReveal, entrance, plant, lightUpArea, item, collisionArea)

func _on_interactive_area_damage_self() -> void:
	damage += 1
	frame += 1
	damage_self.emit()
	if damage == scratchValue:
		match scratchType:
			"Entrance":
				$InteractiveArea.areaType = entrance
				$InteractiveArea.light_on(entranceColour)
			"Item":
				print("reveal item!")
			_:
				$InteractiveArea.light_off()
				$InteractiveArea.monitoring = false
		destroyed.emit()
