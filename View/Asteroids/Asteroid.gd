class_name Asteroid
extends Node2D

signal clicked(asteroid:Asteroid)
signal un_clicked(asteroid:Asteroid)
signal screen_exited(asteroid:Asteroid)

@export var ship: Ship
@export var speed_factor: float = 20.0
@export var respawn_on_screen_exit: bool = false

@export_group("Visual Nodes")
@export var asteroid_sprite: Sprite2D
@export var target_sprite: Sprite2D

@export_group("Ore Colors")
@export var modulate_asteroid_by_ore_content: bool = false
@export var titanium_ore_color: Color
@export var carbon_ore_color: Color
@export var water_ore_color: Color
@export var palladium_ore_color: Color
@export var pyradium_ore_color: Color

var mining_time_available: float = 11.0
var starting_mining_time: float

var titanium_richness: float = 0.0
var carbon_richness: float = 0.0
var water_richness: float = 0.0
var palladium_richness: float = 0.0
var pyralium_richness: float = 0.0

var max_richness: float = 0.0

var _pressed: bool = false
var pressed: bool:
	get():
		return _pressed
	set(value):
		var old_value = _pressed
		_pressed = value
		
		if _pressed and not old_value:
			clicked.emit(self)
			return
			
		if not _pressed and old_value:
			un_clicked.emit(self)
			return

func _ready() -> void:
	target_sprite.visible = false
	asteroid_sprite.rotate(randf() * 400)
	starting_mining_time = mining_time_available
	
	if modulate_asteroid_by_ore_content:
		var color = asteroid_sprite.modulate
		color = color.lerp(titanium_ore_color, titanium_richness)
		color = color.lerp(carbon_ore_color, carbon_richness)
		color = color.lerp(water_ore_color, water_richness)
		color = color.lerp(palladium_ore_color, palladium_richness)
		color = color.lerp(pyradium_ore_color, pyralium_richness)
		asteroid_sprite.modulate = color
	
	max_richness = [
		titanium_richness,
		carbon_richness,
		water_richness,
		palladium_richness,
		pyralium_richness,	
	].max()
	
func _process(delta: float) -> void:
	if mining_time_available <= 0:
		screen_exited.emit(self)
		queue_free()
		return
		
	scale = Vector2.ONE * max_richness * (mining_time_available / starting_mining_time)
	
	if ship.core.speed.isGreaterThan(0.0):
		position.x -= min(20.0, ship.core.speed.exponent + 1) * speed_factor * delta
		
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton and
		event.button_index == MOUSE_BUTTON_LEFT):
		pressed = event.is_pressed()
		event.canceled = true

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	screen_exited.emit(self)
	if respawn_on_screen_exit:
		var viewport_size = get_viewport().get_visible_rect().size
		position.x = viewport_size.x + 64
	else:
		queue_free()

func _on_area_2d_mouse_entered() -> void:
	target_sprite.visible = true

func _on_area_2d_mouse_exited() -> void:
	target_sprite.visible = false
	pressed = false

func can_be_auto_mined() -> bool:
	var viewport_size = get_viewport().get_visible_rect().size
	return position.x < viewport_size.x - 128
