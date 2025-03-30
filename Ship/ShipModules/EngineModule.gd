class_name EngineShipModule
extends ShipModule

@export_group("UI elements")
@export var ui_engine_sprite: Sprite2D
@export var ui_engine_fireballs: SynchronizedChildrenScale
@export var ui_engine_smoke: SynchronizedChildrenScale
#@export var effect_speed_lines: ColorRect
@export var ui_acceleration_label: Label
@export var ui_boost_button: Button
@export var ui_boost_progress: ProgressBar
@export var ui_auto_boost_container: Container
@export var ui_auto_boost_progress: ProgressBar

@export_group("Module Properties")
var base_acceleration := Big.ZERO().setSuffixSeparatorOverride(" ")

var engine_boost_duration_max: float = 3.0
var engine_boost_duration_cooldown_max: float = 5.0
var engine_boost_duration_left: float = 0.0
var engine_boost_duration_cooldown: float = 0.0
var engine_boost := Big.ONE()
@export var engine_boost_curve: Curve

var engine_auto_boost_cooldown_max: float = 0.0
var engine_auto_boost_cooldown: float = 0.0

var boosted_acceleration := Big.ZERO().setSuffixSeparatorOverride(" ")
var mouse_over:bool = false

func get_boost_progress() -> float:
	var boost_progress = 1.0 - engine_boost_duration_left / engine_boost_duration_max
	return boost_progress
	
func get_boost_strength() -> float:
	return engine_boost_curve.sample(get_boost_progress())
	
func update_stats(delta: float) -> void:
	super.update_stats(delta)
	
	# activate auto boost
	if engine_auto_boost_cooldown_max > 0.0:
		engine_auto_boost_cooldown -= delta
		if engine_boost_duration_cooldown <= 0.0 and engine_auto_boost_cooldown <= 0.0:
			engine_auto_boost_cooldown = engine_auto_boost_cooldown_max
			boost_engine()
	
	# calculate current_acceleration with engine boost
	boosted_acceleration = Big.new(base_acceleration)
		
	if engine_boost_duration_left > 0.0:
		engine_boost_duration_left -= delta
		var boost_strength = get_boost_strength()
		if boost_strength >= 1.0:
			pass
		var boost = engine_boost.times(boost_strength)
		boosted_acceleration.plusEquals(boost)
	elif engine_boost_duration_cooldown > 0.0:
		engine_boost_duration_cooldown -= delta
	
	# add current_acceleration to speed
	if boosted_acceleration.isGreaterThan(0.0):
		ship.core.speed.plusEquals(boosted_acceleration.times(delta))
		
func update_ui():
	super.update_ui()
	
	ui_acceleration_label.text = "Acceleration: %sm/s/s" % boosted_acceleration.toMetricSymbol(false)
	
	var boosting = engine_boost_duration_cooldown > 0.0
	ui_boost_button.disabled = boosting
	ui_boost_progress.visible = boosting
	
	if not boosting:
		ui_engine_fireballs.visible = false
		ui_engine_smoke.visible = false
		#effect_speed_lines.visible = false
		ui_engine_sprite.modulate = Color.WHITE	if not mouse_over else Color.AQUAMARINE
	elif engine_boost_duration_left > 0.0:
		ui_engine_fireballs.visible = true
		ui_engine_smoke.visible = true
		ui_boost_progress.max_value = engine_boost_duration_max
		var boost_progress = get_boost_progress()
		ui_boost_progress.value = (engine_boost_duration_max - engine_boost_duration_left) * boost_progress
		ui_boost_progress.modulate = Color.RED
		#effect_speed_lines.visible = true
		#effect_speed_lines.modulate = Color.TRANSPARENT.lerp(Color.WHITE, get_boost_strength() / 2.0)
		var boost_strength = get_boost_strength()
		ui_engine_fireballs.children_scale_factor = engine_boost.mantissa + 2.0
		ui_engine_fireballs.children_scale = Vector2.ONE * boost_strength
		ui_engine_smoke.children_scale = Vector2.ONE
		ui_engine_sprite.modulate = Color.WHITE
	elif engine_boost_duration_cooldown > 0.0:
		ui_engine_fireballs.visible = false
		ui_engine_smoke.visible = true
		#effect_speed_lines.visible = false
		ui_boost_progress.max_value = engine_boost_duration_cooldown_max
		ui_boost_progress.value = engine_boost_duration_cooldown
		ui_engine_smoke.children_scale_factor = 2.0
		ui_engine_smoke.children_scale = Vector2.ONE * engine_boost_duration_cooldown / engine_boost_duration_cooldown_max
		ui_boost_progress.modulate = Color.WHITE
		ui_engine_sprite.modulate = Color.WHITE

	ui_auto_boost_container.visible = engine_auto_boost_cooldown_max > 0.0
	ui_auto_boost_progress.max_value = engine_auto_boost_cooldown_max
	ui_auto_boost_progress.value = engine_auto_boost_cooldown_max - engine_auto_boost_cooldown

func boost_engine() -> void:
	engine_boost_duration_left = engine_boost_duration_max
	engine_boost_duration_cooldown = engine_boost_duration_cooldown_max

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
		if (event is InputEventMouseButton and
		event.button_index == MOUSE_BUTTON_LEFT and
		event.pressed):
			on_click()
			
func _on_boost_engine_button_pressed() -> void:
	on_click()
	
func on_click():
	if ui_boost_button.disabled:
		return
	boost_engine()

func _on_area_2d_mouse_entered() -> void:
	mouse_over = true

func _on_area_2d_mouse_exited() -> void:
	mouse_over = false
