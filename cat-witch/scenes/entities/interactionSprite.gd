extends AnimatedSprite2D

@export_enum("Scratch", "Entrance", "Plant", "Button", "TextHover") var interactionType: String = ""
@export_group("Entrance")
@export_enum("LevelOne", "LevelTwo", "NewTestScene", "CityScape", "AlleyWay", "Greenhouse1", "GreenhouseArea", "LeakyBuilding", "Warehouse", "Building1", "Hub", "Tutorial") var entrance: String
@export var scratchToReveal: bool
@export var location: Vector2i
@export var instant: bool
@export_group("Plant")
@export var plant: AnimatableBody2D
@export_group("Scratch")
@export_enum("Entrance", "Plant", "Reveal", "Item") var scratchType: String
@export_range(0, 5, 1, "or_greater") var scratchValue: int
@export var item: Item
@export_group("Button")
@export var removeStart: Vector2
@export var removeEnd: Vector2
@export var layer: TileMapLayer
@export_enum("Reveal") var buttonType: String
@export_category("")
@export var collisionScale: Vector2
@export var collisionOffset: Vector2
@export var textOffset: Vector2
@export var text: String

var damage: int = 0

func _ready() -> void:
	if not interactionType:
		push_error("Interaction type of interactive area not set: " + self.to_string())
		return
	$InteractiveArea.set_up(interactionType, textOffset, collisionScale, collisionOffset)
	match interactionType:
		"Entrance":
			$InteractiveArea.set_up_entrance(entrance, instant, location)
			if scratchToReveal:
				$InteractiveArea.set_up_scratchable()
		"Plant":
			$InteractiveArea.set_up_plant(plant)
		"Scratch":
			$InteractiveArea.set_up_scratchable(item)
	if interactionType == "TextHover":
		$InteractiveArea/RichTextLabel.add_text(text)

func _on_interactive_area_damage_self() -> void:
	damage += 1
	frame += 1
	if damage == scratchValue:
		match scratchType:
			"Entrance":
				$InteractiveArea.areaType = "Entrance"
				$InteractiveArea.light_on()
			"Item":
				print("reveal item!")
			_:
				$InteractiveArea.light_off()
				$InteractiveArea.monitoring = false

func _on_interactive_area_button_pressed() -> void:
	if buttonType == "Reveal":
		for x: int in range(removeStart.x, removeEnd.x + 1):
			for y: int in range(removeStart.y, removeEnd.y + 1):
				layer.erase_cell(Vector2i(x,y))
		$InteractiveArea.light_off()
		$InteractiveArea.monitoring = false
