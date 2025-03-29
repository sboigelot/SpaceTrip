class_name RadarShipModule
extends ShipModule

@export_group("UI elements")
@export var asteroid_placeholder: Node2D

@export_group("Module Properties")
@export var asteroid_scenes: Array[PackedScene]

var asteroids: Array[Asteroid]

var max_asteroids: int = 3
var asteroid_spawn_min_distance: Big = Big.new(50.0)
var last_asteroid_spawn_distance: Big = Big.ONE().multiplyByEquals(-25.0)

var asteroid_spawn_min_mining_time_available: float = 20.0
var asteroid_spawn_max_mining_time_available: float = 30.0
var asteroid_spawn_titanium_richness: float = 1.0
var asteroid_spawn_carbon_richness: float = 0.0
var asteroid_spawn_water_richness: float = 0.0
var asteroid_spawn_palladium_richness: float = 0.0
var asteroid_spawn_pyralium_richness: float = 0.0
	
func update_stats(delta: float) -> void:
	spawn_asteroids()
	
func spawn_asteroids():
	
	var distance_since_asteroid_spawn = ship.core.distance_travelled.minus(last_asteroid_spawn_distance)
	while distance_since_asteroid_spawn.isGreaterThan(asteroid_spawn_min_distance):
		last_asteroid_spawn_distance = Big.new(ship.core.distance_travelled)
		distance_since_asteroid_spawn = ship.core.distance_travelled.minus(last_asteroid_spawn_distance)
		if asteroids.size() >= max_asteroids:
			break
		
		spawn_asteroid()

func spawn_asteroid():
	
	var asteroid_scene = asteroid_scenes.pick_random()
	var asteroid:Asteroid = asteroid_scene.instantiate()
	asteroid.ship = ship
	
	asteroids.append(asteroid)
	asteroid.screen_exited.connect(_on_asteroid_screen_exited)
	asteroid.screen_exited.connect(ship.mining.on_asteroid_screen_exited)
	asteroid.clicked.connect(ship.mining.on_asteroid_clicked)
	asteroid_placeholder.add_child(asteroid)
	
	var viewport_size = asteroid.get_viewport_rect().size
	asteroid.position = Vector2(
		viewport_size.x + 128,
		randf_range(128, viewport_size.y - 128)
	)
	
	asteroid.titanium_richness = asteroid_spawn_titanium_richness
	asteroid.spawn_carbon_richness = asteroid_spawn_carbon_richness
	asteroid.water_richness = asteroid_spawn_water_richness
	asteroid.palladium_richness = asteroid_spawn_palladium_richness
	asteroid.pyralium_richness = asteroid_spawn_pyralium_richness
	
	asteroid.mining_time_available = randf_range(
		asteroid_spawn_min_mining_time_available,
		asteroid_spawn_max_mining_time_available
	)
	
func _on_asteroid_screen_exited(asteroid:Asteroid):
	asteroids.erase(asteroid)

func update_ui():
	pass
