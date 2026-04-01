extends Panel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var children = self.get_children()
	for i in range(children.size()):
		if children[i] is not Label:
			children[i].mouse_entered.connect(children[i]._on_mouse_entered)
			children[i].mouse_exited.connect(children[i]._on_mouse_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
