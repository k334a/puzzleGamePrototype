extends Node2D

var local_rain
var local_body

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$GPUParticles2D.amount = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	update_position(local_body, local_rain)

func _on_timer_timeout() -> void:
	if $GPUParticles2D.amount < 12:
		$GPUParticles2D.amount += 1

func update_position(body: Node2D, rain: Node2D):
	if body and rain:
		global_position = Vector2(body.global_position.x, rain.global_position.y - 200)

func reset_particles():
	$GPUParticles2D.amount = 1
