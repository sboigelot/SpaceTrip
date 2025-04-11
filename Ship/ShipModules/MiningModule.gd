class_name MiningShipModule
extends ShipModule

@export_group("Laser icons", "laser_icon_")
@export var laser_icon_on: Texture2D
@export var laser_icon_off: Texture2D
@export var laser_icon_auto_on: Texture2D
@export var laser_icon_auto_off: Texture2D
@export var laser_icon_colors: Array[Color]

@export_group("UI elements")
@export var ui_mining_laser_container: Container
@export var ui_mining_laser_icons_placeholder: Container
@export var mining_ray_placeholder: Node2D

@export var mining_ray_scenes_per_global_mining_speed: Dictionary[float, PackedScene]

var titanium:= Big.ZERO()
var carbon:= Big.ZERO()
var water:= Big.ZERO()
var palladium:= Big.ZERO()
var pyralium:= Big.ZERO()

var laser_color_index: int = 0.0
var global_mining_speed_factor: float = 1.0

var titanium_per_second_factor := Big.ONE()
var carbon_per_second_factor := Big.ONE()
var water_per_second_factor := Big.ONE()
var palladium_per_second_factor := Big.ONE()
var pyralium_per_second_factor := Big.ONE()

var max_targeted_asteroids: int = 0
var auto_mine_asteroid_count: int = 0
var unselected_targeted_asteroids: Array[Asteroid]
var player_targeted_asteroids: Array[Asteroid]
var auto_targeted_asteroids: Array[Asteroid]

func get_savable_properties() -> Array[String]:
	return [
		"titanium*",
		"carbon*",
		"water*",
		"palladium*",
		"pyralium*",
		
		"global_mining_speed_factor",
		
		"max_targeted_asteroids",
		"auto_mine_asteroid_count",
	]
	
func _on_loaded():
	unselected_targeted_asteroids.clear()
	player_targeted_asteroids.clear()
	auto_targeted_asteroids.clear()
	
func update_stats(delta: float) -> void:
	auto_mine_asteroids()
	
	for targeted_asteroid in player_targeted_asteroids:
		mine_asteroid(targeted_asteroid, delta)
		
	for targeted_asteroid in auto_targeted_asteroids:
		mine_asteroid(targeted_asteroid, delta)

func get_targeted_asteroid_count() -> int:
	return player_targeted_asteroids.size() + auto_targeted_asteroids.size()
		
func auto_mine_asteroids():
	var asteroid_request_count = max(0, auto_mine_asteroid_count - get_targeted_asteroid_count())
	if asteroid_request_count == 0:
		return
		
	var new_targets: Array[Asteroid] = []
	var all_asteroids = ship.radar.asteroids.duplicate()
	all_asteroids.shuffle()
	for asteroid in all_asteroids:
		if not asteroid.can_be_auto_mined():
			continue
		
		if unselected_targeted_asteroids.has(asteroid):
			continue
		
		if player_targeted_asteroids.has(asteroid):
			continue
			
		if auto_targeted_asteroids.has(asteroid):
			continue
			
		new_targets.append(asteroid)
		if new_targets.size() >= asteroid_request_count:
			break
			
	auto_targeted_asteroids.append_array(new_targets)
		
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
	
	for i in ui_mining_laser_icons_placeholder.get_child_count():
		var laser_icon:TextureRect = ui_mining_laser_icons_placeholder.get_child(i)
		
		laser_icon.visible = i < max_targeted_asteroids
		if not laser_icon.visible:
			continue
		
		laser_icon.modulate = laser_icon_colors[laser_color_index]
		
		var is_auto_on = i < auto_targeted_asteroids.size()
		var is_player_on = not is_auto_on and i < get_targeted_asteroid_count()
		
		if is_auto_on:
			laser_icon.texture = laser_icon_auto_on
		elif is_player_on:
			laser_icon.texture = laser_icon_on
		elif i < auto_mine_asteroid_count:
			laser_icon.texture = laser_icon_auto_off
		else:
			laser_icon.texture = laser_icon_off
	
	target_mining_rays()
	
func target_mining_rays():

	#if upgrading lasers
	if mining_ray_placeholder.get_child_count() > max_targeted_asteroids:
		for mining_ray in mining_ray_placeholder.get_children():
			mining_ray_placeholder.remove_child(mining_ray)
			mining_ray.queue_free()
		player_targeted_asteroids.clear()
		auto_targeted_asteroids.clear()
	
	for mining_ray in mining_ray_placeholder.get_children():
		mining_ray.visible = false
	
	var all_tragetted_asteroids: Array[Asteroid]
	all_tragetted_asteroids.append_array(player_targeted_asteroids)
	all_tragetted_asteroids.append_array(auto_targeted_asteroids)
	
	while mining_ray_placeholder.get_child_count() <= all_tragetted_asteroids.size():
		spawn_mining_ray()
		
	var available_rays:Array[MiningRay]
	available_rays.assign(mining_ray_placeholder.get_children())
	
	for targeted_asteroid in all_tragetted_asteroids:
		var selected_mining_ray: MiningRay
		
		for mining_ray in available_rays:
			
			if (not is_instance_valid(mining_ray.last_targetted_asteroid) or 
				mining_ray.last_targetted_asteroid.is_queued_for_deletion()):
				mining_ray.last_targetted_asteroid = null
					
			if mining_ray.last_targetted_asteroid == targeted_asteroid:
				selected_mining_ray = mining_ray
				break
				
			if mining_ray.last_targetted_asteroid == null:
				selected_mining_ray = mining_ray
				continue
				
		if selected_mining_ray == null:
			selected_mining_ray = available_rays[0]
		
		selected_mining_ray.target(targeted_asteroid)
		available_rays.erase(selected_mining_ray)

func spawn_mining_ray():
	var mining_ray_scene: PackedScene
	for dictionary_key in mining_ray_scenes_per_global_mining_speed.keys():
		if dictionary_key > global_mining_speed_factor:
			break
		mining_ray_scene = mining_ray_scenes_per_global_mining_speed[dictionary_key] 	
	
	var mining_ray = mining_ray_scene.instantiate()
	laser_color_index = mining_ray.laser_color_index
	mining_ray.visible = false
	mining_ray_placeholder.add_child(mining_ray)
	
func on_asteroid_screen_exited(asteroid:Asteroid) -> void:
	unselected_targeted_asteroids.erase(asteroid)
	player_targeted_asteroids.erase(asteroid)
	auto_targeted_asteroids.erase(asteroid)

func on_asteroid_clicked(asteroid:Asteroid) -> void:
	cycle_target_asteroid(asteroid)
	
func cycle_target_asteroid(asteroid:Asteroid):
	
	if player_targeted_asteroids.has(asteroid) or auto_targeted_asteroids.has(asteroid):
		player_targeted_asteroids.erase(asteroid)
		auto_targeted_asteroids.erase(asteroid)
		unselected_targeted_asteroids.append(asteroid)
	else:
		player_targeted_asteroids.append(asteroid)
		unselected_targeted_asteroids.erase(asteroid)
		
	var max_asteroids: int = max(0, max_targeted_asteroids)
	while get_targeted_asteroid_count() > max_asteroids:
		if auto_targeted_asteroids.size() > 0:
			auto_targeted_asteroids.pop_front()
		elif player_targeted_asteroids.size() > 0:
			player_targeted_asteroids.pop_front()
		else:
			printerr("Impossible to reduce targeted asteroid count")
			break
		
	
