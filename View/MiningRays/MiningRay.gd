class_name MiningRay
extends MarginContainer

@export var mining_particules: GPUParticles2D
@export var laser_color_index: int

var last_targetted_asteroid:Asteroid

func _process(delta: float) -> void:
	update_ui()
	
func update_ui():
	if visible and not mining_particules.emitting:
		mining_particules.restart()
		mining_particules.emitting = true
	if not visible and mining_particules.emitting:
		last_targetted_asteroid = null
		mining_particules.emitting = false

func target(asteroid:Asteroid):
	last_targetted_asteroid = asteroid
	
	visible = true
	var target_position = asteroid.global_position
	if target_position.y <= get_viewport().size.y / 2.0:
		target_position -= pivot_offset
	else:
		target_position += pivot_offset
	var angle_to_asteroid = global_position.angle_to_point(target_position)
	rotation = angle_to_asteroid
	var distance_to_asteroid = global_position.distance_to(target_position)
	size.x = distance_to_asteroid
