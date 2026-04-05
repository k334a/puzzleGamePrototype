extends AnimatedSprite2D

@export_enum("Scratch", "Entrance", "Plant", "Button", "TextHover", "UseItem") var interactionType: String = ""

@export_group("Entrance")
@export_enum("Tutorial", "Hub", "CityScape", "Building1", "LeakyBuilding", "Floor1", "ElevatorShaft", "Warehouse", "WarehouseVents", "WarehouseOffice", "WarehouseMain", "AlleyWay", "GreenhouseArea", "Greenhouse1", "LevelOne", "LevelTwo", "NewTestScene") var entrance: String
@export var location: Vector2i
@export var instant: bool

@export_subgroup("Unlock Entrance")
@export var scratchToReveal: bool
@export var itemToReveal: bool
@export var unlocksEntrance: bool
@export_enum("Tutorial", "Hub", "CityScape", "Building1", "LeakyBuilding", "Floor1", "ElevatorShaft", "Warehouse", "WarehouseVents", "WarehouseOffice", "WarehouseMain", "AlleyWay", "GreenhouseArea", "Greenhouse1", "LevelOne", "LevelTwo", "NewTestScene") var entranceFrom: String
@export var locked: bool

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
@export_enum("Reveal", "Spigot", "LeverToggle", "TimerButton") var buttonType: String
@export var spigotTiles: Array[Vector2i]

@export_group("Item")
@export var needsItemName: String

@export_category("")
@export var collisionScale: Vector2
@export var collisionOffset: Vector2
@export var textOffset: Vector2
@export var textBoxScale: Vector2
@export var text: String

var damage: int = 0
var itemUsed: bool = false

func _ready() -> void:
	if not interactionType:
		push_error("Interaction type of interactive area not set: " + self.to_string())
		return
	$InteractiveArea.set_up(interactionType, textOffset, textBoxScale, collisionScale, collisionOffset)
	match interactionType:
		"Entrance":
			$InteractiveArea.set_up_entrance(entrance, instant, location, locked, unlocksEntrance, entranceFrom)
			if scratchToReveal:
				$InteractiveArea.set_up_scratchable()
		"Plant":
			$InteractiveArea.set_up_plant(plant)
		"Scratch":
			$InteractiveArea.set_up_scratchable(item)
		"Button":
			$InteractiveArea.set_up_button(buttonType, spigotTiles, layer)
		"TextHover":
			$InteractiveArea/RichTextLabel.text = "[wave amp=10 freq=5]" + text
		"UseItem":
			$InteractiveArea/RichTextLabel.text = "[wave amp=10 freq=5]" + text
			if needsItemName:
				$InteractiveArea.set_up_itemUse(needsItemName)

func _on_interactive_area_damage_self() -> void:
	damage += 1
	frame += 1
	if damage == scratchValue:
		match scratchType:
			"Entrance":
				$InteractiveArea.areaType = "Entrance"
				$InteractiveArea/RichTextLabel.text = "[wave amp=10 freq=5]Enter"
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

func _on_interactive_area_item_used() -> void:
	if itemToReveal:
		animation = "item_used"
		print("item used...")
		itemUsed = true
