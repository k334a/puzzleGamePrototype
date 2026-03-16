extends CanvasLayer
class_name InventoryUI

@onready var grid: GridContainer = $Control/Panel/GridContainer

const SlotScene = preload("res://scenes/slot.tscn")

func _ready() -> void:
	visible = false


func refresh(inventory: Inventory) -> void: 
	for child in grid.get_children():
		child.queue_free()
	
	for item in inventory.items:
		var slot = SlotScene.instantiate()
		grid.add_child(slot)
		slot.set_item(item)

func toggle(inventory: Inventory) -> bool:
	visible = !visible
	if visible:
		refresh(inventory)
	return visible
