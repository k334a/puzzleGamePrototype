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
@export_category("Animation")
@export var damageFrameOffset: int
var damage: int = 0

signal damage_self
signal destroyed

func _ready() -> void:
	if not interactionType:
		push_error("Interaction type of interactive area not set: " + self.to_string())
	
	$InteractiveArea.scratchable = (not interactionType == "Entrance" or scratchToReveal)
	match interactionType:
		"Entrance" when not scratchToReveal:
			$InteractiveArea.entranceLevel = entrance
		"Plant":
			$InteractiveArea.plantNode = plant
		"":
			$InteractiveArea.areaType = "scratch"
			if scratchToReveal:
				$InteractiveArea.entranceLevel = entrance
			if item:
				$InteractiveArea.item = item

func _on_interactive_area_damage_self() -> void:
	damage += 1
	if damage == scratchValue:
		match scratchType:
			"Entrance":
				$InteractiveArea.areaType = entrance
				$InteractiveArea.light_on(entranceColour)
			"Item":
				print("reveal item!")
			"":
				$InteractiveArea.light_off()
				$InteractiveArea.monitoring = false
				hide()
		destroyed.emit()
	else:
		frame += damageFrameOffset * damage
		damage_self.emit()

func resetPlant() -> void:
	show()
	$InteractiveArea.monitoring = true
	$InteractiveArea.areaType = "plant"
	damage = 0

func plantUnfurled() -> void:
	$InteractiveArea.areaType = "Scratch"

func plantFurled() -> void:
	$InteractiveArea.areaType = "Plant"
