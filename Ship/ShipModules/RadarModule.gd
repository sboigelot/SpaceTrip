class_name RadarShipModule
extends ShipModule

@export_group("UI elements")
@export var ui_asteroid_placeholder: Node2D
@export var ui_asteroid_scenes: Array[PackedScene]

@export_group("Module Properties")

var asteroids: Array[Asteroid]

var max_asteroids: int = 3
var asteroid_spawn_min_distance: Big = Big.new(50.0)
var last_asteroid_spawn_distance: Big = Big.ONE().plusEquals(asteroid_spawn_min_distance.times(1.5))

var asteroid_spawn_min_mining_time_available: float = 20.0
var asteroid_spawn_max_mining_time_available: float = 30.0

var asteroid_spawn_titanium_chance: float = 1.0
var asteroid_spawn_carbon_chance: float = 0.0
var asteroid_spawn_water_chance: float = 0.0
var asteroid_spawn_palladium_chance: float = 0.0
var asteroid_spawn_pyralium_chance: float = 0.0
	
func get_savable_properties() -> Array[String]:
	return [
		"max_asteroids",
		"asteroid_*",
		"last_asteroid_spawn_distance",
	]
	
func _on_loaded():
	for asteroid in asteroids:
		asteroid.queue_free()
	asteroids.clear()
	
func update_stats(delta: float) -> void:
	spawn_asteroids()
	
func spawn_asteroids():
	
	var real_max_asteroids = max_asteroids * (
		asteroid_spawn_titanium_chance +
		asteroid_spawn_carbon_chance +
		asteroid_spawn_water_chance +
		asteroid_spawn_palladium_chance +
		asteroid_spawn_pyralium_chance
	)
	
	var distance_since_asteroid_spawn = ship.core.distance_travelled.minus(last_asteroid_spawn_distance)
	while distance_since_asteroid_spawn.isGreaterThan(asteroid_spawn_min_distance):
		last_asteroid_spawn_distance = Big.new(ship.core.distance_travelled)
		distance_since_asteroid_spawn = ship.core.distance_travelled.minus(last_asteroid_spawn_distance)
		if asteroids.size() >= real_max_asteroids:
			break
		
		spawn_asteroid()

func get_random_asteroid_resource() -> String:
	const all_possible_resources = [
		"titanium",
		"carbon",
		"water",
		"palladium",
		"pyralium"
	]
	
	var weights:Array
	for possible_resource in all_possible_resources:
		var property = "asteroid_spawn_%s_chance" % possible_resource
		weights.append(self[property])
	
	var random_resource =  WeightedRandom.pick(
		all_possible_resources,
		weights
	)
	
	return random_resource

func spawn_asteroid():
	
	var asteroid_scene = ui_asteroid_scenes.pick_random()
	var asteroid:Asteroid = asteroid_scene.instantiate()
	asteroid.ship = ship
	
	var asteroid_resource = get_random_asteroid_resource()
	asteroid["%s_richness" % asteroid_resource] =  1.0
	
	asteroid.mining_time_available = randf_range(
		asteroid_spawn_min_mining_time_available,
		asteroid_spawn_max_mining_time_available
	)
	
	asteroids.append(asteroid)
	asteroid.screen_exited.connect(_on_asteroid_screen_exited)
	asteroid.screen_exited.connect(ship.mining.on_asteroid_screen_exited)
	asteroid.clicked.connect(ship.mining.on_asteroid_clicked)
	ui_asteroid_placeholder.add_child(asteroid)
	
	var viewport_size = get_viewport().get_visible_rect().size
	
	var spawn_position = Vector2(
		viewport_size.x + 64,
		randf_range(64, viewport_size.y - 64)
	)
	
	var center_y = viewport_size.y / 2.0
	const center_margin: float = 128.0
	if spawn_position.y > center_y - center_margin and spawn_position.y < center_y + center_margin:
		if spawn_position.y < center_y:
			spawn_position.y -= center_margin
		else:
			spawn_position.y += center_margin
		
	asteroid.position = spawn_position
	
	
func _on_asteroid_screen_exited(asteroid:Asteroid):
	asteroids.erase(asteroid)

func update_ui():
	pass
