class_name EngineShipModule
extends ShipModule

@export_group("UI elements")
@export var ui_acceleration_label: Label
@export var ui_boost_button: Button
@export var ui_boost_progress: ProgressBar

@export_group("Module Properties")
var base_acceleration := Big.ZERO().setSuffixSeparatorOverride(" ")
var current_acceleration := Big.ZERO().setSuffixSeparatorOverride(" ")
var base_acceleration_drag_factor_per_second: float = 1.0

var engine_boost_duration_max: float = 1.0
var engine_boost_duration_cooldown_max: float = 5.0
var engine_boost_duration_left: float = 0.0
var engine_boost_duration_cooldown: float = 0.0
var engine_boost := Big.ONE().multiplyBy(0.25)
@export var engine_boost_curve: Curve

var boosted_acceleration := Big.ZERO().setSuffixSeparatorOverride(" ")

func get_boost_progress() -> float:
	var boost_progress = 1.0 - engine_boost_duration_left / engine_boost_duration_max
	return boost_progress
	
func update_stats(delta: float) -> void:
	super.update_stats(delta)
	
	# calculate current_acceleration with engine boost
	boosted_acceleration = Big.new(base_acceleration)
		
	if engine_boost_duration_left > 0.0:
		engine_boost_duration_left -= delta
		var boost_progress = get_boost_progress()
		var boost_strength = engine_boost_curve.sample(boost_progress)
		var boost = engine_boost.multiplyBy(boost_strength)
		boosted_acceleration.plusEquals(boost)
	elif engine_boost_duration_cooldown > 0.0:
		engine_boost_duration_cooldown -= delta
	
	# add current_acceleration to speed
	if boosted_acceleration.isGreaterThan(0.0):
		ship.core.speed.plusEquals(boosted_acceleration.multiplyBy(delta))
		
	# drag acceleration --> WARNING NOT TESTED
	if current_acceleration.isGreaterThan(base_acceleration):
		var base_accleration_drag = 1.0 - base_acceleration_drag_factor_per_second * delta
		current_acceleration.multiplyByEquals(base_accleration_drag)
	
func update_ui():
	super.update_ui()
	
	ui_acceleration_label.text = "Acceleration: %sm/s/s" % boosted_acceleration.toMetricSymbol(false)
	ui_boost_button.disabled = engine_boost_duration_cooldown > 0.0
	ui_boost_progress.visible = ui_boost_button.disabled
	if engine_boost_duration_left > 0.0:
		ui_boost_progress.max_value = engine_boost_duration_max
		var boost_progress = get_boost_progress()
		ui_boost_progress.value = (engine_boost_duration_max - engine_boost_duration_left) * boost_progress
		ui_boost_progress.modulate = Color.RED
	elif engine_boost_duration_cooldown > 0.0:
		ui_boost_progress.max_value = engine_boost_duration_cooldown_max
		ui_boost_progress.value = engine_boost_duration_cooldown
		ui_boost_progress.modulate = Color.WHITE

func _on_boost_engine_button_pressed() -> void:
	engine_boost_duration_left = engine_boost_duration_max
	engine_boost_duration_cooldown = engine_boost_duration_cooldown_max
	
