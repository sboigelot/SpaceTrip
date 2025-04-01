class_name MiningShipModule
extends ShipModule

@export_group("UI elements")
@export var ui_mining_laser_container: Container
@export var ui_mining_laser_label: Label
@export var mining_ray_placeholder: Node2D

@export var mining_ray_scenes_per_global_mining_speed: Dictionary[float, PackedScene]

var titanium:= Big.ZERO()
var carbon:= Big.ZERO()
var water:= Big.ZERO()
var palladium:= Big.ZERO()
var pyralium:= Big.ZERO()

var global_mining_speed_factor: float = 1.0

var titanium_per_second_factor := Big.ONE()
var carbon_per_second_factor := Big.ONE()
var water_per_second_factor := Big.ONE()
var palladium_per_second_factor := Big.ONE()
var pyralium_per_second_factor := Big.ONE()

var max_targeted_asteroids: int = 0
var auto_mine_asteroid_count: int = 0
var targeted_asteroids: Array[Asteroid]

func update_stats(delta: float) -> void:
	auto_mine_asteroids()
	
	for targeted_asteroid in targeted_asteroids:
		mine_asteroid(targeted_asteroid, delta)
	
func auto_mine_asteroids():
	var asteroid_request_count = max(0, auto_mine_asteroid_count - targeted_asteroids.size())
	if asteroid_request_count == 0:
		return
		
	var new_targets: Array[Asteroid] = []
	for asteroid in ship.radar.asteroids:
		if not asteroid.can_be_auto_mined():
			continue
			
		if targeted_asteroids.has(asteroid):
			continue
			
		new_targets.append(asteroid)
		if new_targets.size() >= asteroid_request_count:
			break
			
	targeted_asteroids.append_array(new_targets)
		
func mine_asteroid(asteroid: Asteroid, delta: float) -> void:
	var mining_delta = global_mining_speed_factor * delta
	asteroid.mining_time_available -= mining_delta
	if asteroid.mining_time_available <= 0.0:
		return
	
	mine_asteroid_resource(titanium, titanium_per_second_factor, asteroid.titanium_richness, mining_delta)
	mine_asteroid_resource(carbon, carbon_per_second_factor, asteroid.carbon_richness, mining_delta)
	mine_asteroid_resource(water, water_per_second_factor, asteroid.water_richness, mining_delta)
	mine_asteroid_resource(palladium, palladium_per_second_factor, asteroid.palladium_richness, mining_delta)
	mine_asteroid_resource(pyralium, pyralium_per_second_factor, asteroid.pyralium_richness, mining_delta)

func mine_asteroid_resource(core_stock:Big, 
							core_mining_per_second_factor: Big, 
							asteroid_richness: float, 
							delta: float):
	if asteroid_richness > 0:
		core_stock.plusEquals(core_mining_per_second_factor.
					times(delta).
					times(asteroid_richness))
	
	
func update_ui():
	ui_mining_laser_container.visible = max_targeted_asteroids > 0
	ui_mining_laser_label.text = "Mining laser: %d / %d%s" % [
		targeted_asteroids.size(),
		max_targeted_asteroids,
		(" (%d auto)" % auto_mine_asteroid_count) if auto_mine_asteroid_count > 0 else ""
	]
	
	target_mining_rays()
	
func target_mining_rays():
	if mining_ray_placeholder.get_child_count() > max_targeted_asteroids:
		for mining_ray in mining_ray_placeholder.get_children():
			mining_ray_placeholder.remove_child(mining_ray)
			mining_ray.queue_free()
	
	for mining_ray in mining_ray_placeholder.get_children():
		mining_ray.visible = false
		
	var ray_index = 0
	for targeted_asteroid in targeted_asteroids:
		ray_index += 1
		target_ray_towards(ray_index, targeted_asteroid)
	
func target_ray_towards(ray_index: int, asteroid: Asteroid):
	while ray_index >= mining_ray_placeholder.get_child_count():
		spawn_mining_ray()
		
	var mining_ray = mining_ray_placeholder.get_child(ray_index)
	mining_ray.target(asteroid)

func spawn_mining_ray():
	var mining_ray_scene: PackedScene
	for dictionary_key in mining_ray_scenes_per_global_mining_speed.keys():
		if dictionary_key > global_mining_speed_factor:
			break
		mining_ray_scene = mining_ray_scenes_per_global_mining_speed[dictionary_key] 	
	
	var mining_ray = mining_ray_scene.instantiate()
	mining_ray.visible = false
	mining_ray_placeholder.add_child(mining_ray)
	
func on_asteroid_screen_exited(asteroid:Asteroid) -> void:
	targeted_asteroids.erase(asteroid)

func on_asteroid_clicked(asteroid:Asteroid) -> void:
	cycle_target_asteroid(asteroid, true)
	
func cycle_target_asteroid(asteroid:Asteroid, erase_on_re_target: bool = false):
	if targeted_asteroids.has(asteroid):
		targeted_asteroids.erase(asteroid)
		if not erase_on_re_target: #push to the back
			targeted_asteroids.append(asteroid)
	else:
		targeted_asteroids.append(asteroid)
		
	var max_asteroids: int = max(0, max_targeted_asteroids)
	while targeted_asteroids.size() > max_asteroids:
		targeted_asteroids.pop_front()
		
	
