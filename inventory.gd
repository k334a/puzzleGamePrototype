extends Node 

@export var inventory_size := 20

car items: Array[]

func _ready():
    items.resize(inventory_size)

func add_item(item: Item) -> bool:
    for i in range(items.size()):
        if items[i] == null:
            items[i] = item
            return true # end loop, found empty space for item
    return false # inventory full

func remove_item(index: int) -> bool:
    if items[index] != null:
        return false
    items[index] = null
        return true

