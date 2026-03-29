extends Sprite2D

@export var entrance: PackedScene

func _ready() -> void:
	$InteractiveArea.entranceLevel = entrance
