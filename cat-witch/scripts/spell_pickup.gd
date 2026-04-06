extends Area2D
class_name SpellPickup

@export var item: Item = null
# SIGNALS

var collected: bool = false

signal picked_up(item: Item)

func _ready() -> void:
	$Sprite2D.texture = item.icon
	if collected:
		queue_free()

func _on_body_entered(body: Node) -> void:
	# under Node, Groups add "player" to cat.
	if not body.is_in_group("player"):
		return
	
	if item == null:
		push_warning("SpellPickup has no item assigned!")
		return
	
	if "inventory" in body:
		var success = false
		if item.isSpell:
			success = body.inventory.add_spell(item)
		else:
			success = body.inventory.add_item(item)
			
		if success:
			print("DEBUG: pickup successful")
			picked_up.emit(item)
			queue_free()
		else:
			print("DEBUG: Something went wrong. Maybe, Inventory full!")
