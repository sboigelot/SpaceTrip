class_name MiningRay
extends MarginContainer

@export var mining_particules: GPUParticles2D

func _process(delta: float) -> void:
	update_ui()
	
func update_ui():
	if visible and not mining_particules.emitting:
		mining_particules.restart()
		mining_particules.emitting = true
	if not visible and mining_particules.emitting:
		mining_particules.emitting = false

func target(asteroid:Asteroid):
	visible = true
	var angle_to_asteroid = global_position.angle_to_point(asteroid.global_position)
	rotation = angle_to_asteroid
	var distance_to_asteroid = global_position.distance_to(asteroid.global_position)
	size.x = distance_to_asteroid
