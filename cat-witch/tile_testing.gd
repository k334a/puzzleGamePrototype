extends TileMapLayer

var center = Vector2i(6,6)
var radius = 6

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var top = ceil(center.x - radius)
		var bottom = floor(center.y + radius)
		var y = top
		while y <= bottom:
			var dy = y - center.y
			var dx = floor(sqrt(radius*radius - dy*dy))
			var left = center.x - dx
			var right = center.x + dx
			print("y: ", y)
			print("    left: ", Vector2i(left,y))
			print("    right: ", Vector2i(right,y))
			set_cell(Vector2i(left,y),get_cell_source_id(Vector2i(left,y)),get_cell_atlas_coords(Vector2i(left,y)) + Vector2i(4,0),get_cell_alternative_tile(Vector2i(left,y)))
			set_cell(Vector2i(right,y),get_cell_source_id(Vector2i(right,y)),get_cell_atlas_coords(Vector2i(right,y)) + Vector2i(4,0),get_cell_alternative_tile(Vector2i(right,y)))
			y += 1
