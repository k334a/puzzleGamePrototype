extends Sprite2D

@export_enum("Scratch", "Entrance", "Plant") var interactionType: String
@export_group("Entrance")
@export var entrance: String
@export var scratchToReveal: bool
@export_group("Plant")
@export var plant: AnimatableBody2D
@export_group("Scratch")
@export_enum("Entrance", "Plant", "Reveal", "Item") var scratchType: String
@export_range(0, 5, 1, "or_greater") var scratchValue: int
@export var item: Item

func _ready() -> void:
	if not interactionType:
		push_error("Interaction type of interactive area not set: " + self.to_string())
	match interactionType:
		"Entrance" when not scratchToReveal:
			$InteractiveArea.entranceLevel = entrance
			$InteractiveArea.areaType = "entrance"
		"Plant":
			$InteractiveArea.plantNode = plant
			$InteractiveArea.areaType = "plant"
			$InteractiveArea.scratchType[plant] = scratchValue
		"":
			$InteractiveArea.areaType = "scratch"
			$InteractiveArea.scratchType = scratchType
			$InteractiveArea.scratchValue = scratchValue
			if entrance:
				$InteractiveArea.entranceLevel = entrance
			if item:
				$InteractiveArea.item = item

func _on_interactive_area_damage_self() -> void:
	pass #Update sprite to reflect damage from scratching

func _on_interactive_area_destroyed() -> void:
	hide()
