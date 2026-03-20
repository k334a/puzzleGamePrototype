extends Node 
class_name Inventory

@export var inventory_size := 8

signal updated

var items: Array

func _ready():
	items = []
	items.resize(inventory_size)

func add_item(item: Item) -> bool:
	for i in range(items.size()):
		if items[i] == null:
			items[i] = item
			updated.emit()
			print("test, item added to slot", i)
			return true # end loop, found empty space for item
	return false # inventory full

func remove_item(index: int) -> bool: #test if you can remove an item
	if items[index] != null:
		return true
	items[index] = null
	return false
