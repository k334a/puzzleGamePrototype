extends Node2D

var player_in: CharacterBody2D

func _physics_process(_delta: float) -> void:
	if player_in and player_in.is_on_floor():
		$AudioStreamPlayer.play()
		$StaticBody2D/TileMapLayer.enabled = false
		$StaticBody2D/TileMapLayer2.enabled = false
		$StaticBody2D.hide()
		
		$StaticBody2D2/TileMapLayer2.enabled = true
		$StaticBody2D2.show()
		
		$Area2D.monitoring = false

func reset() -> void:
	$StaticBody2D/TileMapLayer.enabled = true
	$StaticBody2D/TileMapLayer2.enabled = true
	$StaticBody2D.show()
	$StaticBody2D2/TileMapLayer2.enabled = false
	$StaticBody2D2.hide()
	$Area2D.monitoring = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in = body

func _on_area_2d_body_exited(_body: Node2D) -> void:
	player_in = null
