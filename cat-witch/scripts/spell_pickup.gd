extends Area2D
class_name SpellPickup

@export var item: Item = null
# SIGNALS

signal picked_up(item: Item)

# note: runs once when this node first enters the scene.
func _ready() -> void:
	
	# "body_entered" is a built-in Area2D signal.
	# It fires whenever a PhysicsBody enters this area.
	# We point it at our own _on_body_entered function below.
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:

	# under Node, Groups add "player" to cat.
	if not body.is_in_group("player"):
		return  

	if item == null:
		push_warning("SpellPickup has no item assigned!")
		return

	if "inventory" in body:
		var success = body.inventory.add_item(item)
		if success:
			print("DEBUG: pickup successful")
			picked_up.emit(item)
			queue_free()
		else:
			print("DEBUG: Something went wrong. Maybe, Inventory full!")
