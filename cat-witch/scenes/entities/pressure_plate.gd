extends AnimatableBody2D

var weights: Array[Node2D] = []
@export var weightLimit: int = 4
@export var removeStart: Vector2
@export var removeEnd: Vector2
@export var layer: TileMapLayer
var removed: bool = false

signal weightHit

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("pushable") and weights.find(body) == -1:
		weights.push_back(body)
		if weights.size() <= weightLimit:
			$AnimationPlayer.play_section_with_markers("compress", str(weights.size()), str(weights.size()+1), -1, 10)
			await $AnimationPlayer.animation_started
	if weights.size() >= weightLimit and not removed:
		weighedDown()
		weightHit.emit()
		removed = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("pushable") and weights.find(body) != -1:
		if weights.size() <= weightLimit:
			$AnimationPlayer.play_section_with_markers("compress", str(weights.size()), str(weights.size()+1), -1, -10, true)
			await $AnimationPlayer.animation_started
		weights.remove_at(weights.find(body))

func weighedDown() -> void:
	for x: int in range(removeStart.x, removeEnd.x + 1):
		for y: int in range(removeStart.y, removeEnd.y + 1):
			layer.erase_cell(Vector2i(x,y))

func reset() -> void:
	$AnimationPlayer.play("RESET")
