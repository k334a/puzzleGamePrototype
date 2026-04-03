extends CanvasLayer
class_name InventoryUI

@onready var grid: GridContainer = $Control/Panel/GridContainer
@onready var spellPanel: Panel = $Control/SpellPanel
var totalJars: int = 0
var brokenJars: int = 0

const SlotScene = preload("res://scenes/Inventory_and_Items/slot.tscn")
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
		if slot is Label:
			continue
		if i < inventory.spells.size():
			slot.set_item(inventory.spells[i])
		else:
			slot.clear()  # optional: empty slot


func toggle(inventory: Inventory) -> bool:
	visible = !visible
	if visible:
		refresh(inventory)
	return visible

func update_vases(broke: bool, total: int=0) -> void:
	if broke:
		brokenJars += 1
	if total == 0:
		total = totalJars
	else:
		totalJars = total
	$RichTextLabel.text = "Vases Broken: " + String.num_int64(brokenJars) + "/" + String.num_int64(total)

func show_jars() -> void:
	show()
	$Control.hide()
	await get_tree().create_timer(2, false).timeout
	$Control.show()
	hide()
