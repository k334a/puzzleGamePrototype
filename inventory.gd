extends Node 

@export var inventory_size := 20

car items: Array

func _ready():
    items.resize(inventory_size)

func add_item(item: Item) -> bool:
    for i in range(items.size()):
        if items[i] == null:
            items[i] = item
            return true # end loop, found empty space for item
    return false # inventory full

func remove_item(index: int) -> bool: #test if you can remove an item
    if items[index] != null:
        return true
    items[index] = null
        return false

