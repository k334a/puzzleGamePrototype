extends TileMapLayer

var radius = 4
var center = Vector2i(5,5)
var corners: Array[int] 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var r = floor(radius * sqrt(0.5))
		draw(center.x - radius, center.y)
		draw(center.x + radius, center.y)
		draw(center.x, center.y - radius)
		draw(center.x, center.y + radius)
		while r >= 0:
			var d = floor(sqrt(radius*radius - r*r))
			print("r: ",r,", d: ",d)
			if abs(r) == abs(d):
				print("pushing corner...")
				corners.push_back(abs(r))
			elif not r == 0 and not d == radius:
				draw(center.x - d, center.y + r)
				draw(center.x + d, center.y + r)
				draw(center.x + d, center.y - r)
				draw(center.x - d, center.y - r)
				draw(center.x - r, center.y + d)
				draw(center.x + r, center.y + d)
				draw(center.x + r, center.y - d)
				draw(center.x - r, center.y - d)
			r -= 1
		for corner in corners:
			draw(center.x + corner, center.y + corner)
			draw(center.x - corner, center.y + corner)
			draw(center.x - corner, center.y - corner)
			draw(center.x + corner, center.y - corner)
	set_cell(Vector2i(center.x + radius / 2, center.y + radius / 2),get_cell_source_id(Vector2i(center.x + radius / 2, center.y + radius / 2)),get_cell_atlas_coords(Vector2i(center.x + radius / 2, center.y + radius / 2)) + Vector2i(0,5),get_cell_alternative_tile(Vector2i(center.x + radius / 2, center.y + radius / 2)))

func draw(h: int, v: int) -> void:
	print("\t h: ",h,", v: ",v)
	set_cell(Vector2i(h,v),get_cell_source_id(Vector2i(h,v)),get_cell_atlas_coords(Vector2i(h,v)) + Vector2i(0,5),get_cell_alternative_tile(Vector2i(h,v)))
