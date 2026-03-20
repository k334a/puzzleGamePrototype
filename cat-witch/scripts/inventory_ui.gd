extends CanvasLayer
class_name InventoryUI

@onready var grid: GridContainer = $Control/Panel/GridContainer
@onready var spellPanel: Panel = $Control/SpellPanel

const SlotScene = preload("res://scenes/slot.tscn")

func _ready() -> void:
	visible = false

func refresh(inventory: Inventory) -> void: 
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()
	
	for item in inventory.items:
		var slot = SlotScene.instantiate()
		grid.add_child(slot)
		slot.set_item(item)
	
	var slots = spellPanel.get_children()

	for i in range(slots.size()):
		var slot = slots[i]
		if i < inventory.spells.size():
			slot.set_item(inventory.spells[i])
		else:
			slot.clear()  # optional: empty slot


func toggle(inventory: Inventory) -> bool:
	visible = !visible
	if visible:
		refresh(inventory)
	return visible
