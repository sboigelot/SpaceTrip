class_name RefineryProcessPanel
extends BoxContainer

@export var ship: Ship
@export var resource_input: String
@export var resource_output: String

@export var ui_input_label: Label
@export var ui_progress_bar: ProgressBar
@export var ui_output_label: Label

func check_unlocked() -> void:
	visible = get_refining_duration() > 0.0

func _ready() -> void:
	check_unlocked()
	update_ui()
	
func _process(delta: float) -> void:
	update_ui()
	
func get_refining_duration() -> float:
	return ship.refinery["%s_refining_duration" % resource_output]
	
func get_refining_progress() -> float:
	return ship.refinery["%s_refining_progress" % resource_output]
	
func get_refining_input_big() -> Big:
	var property_name = "%s_refining_input_%s" % [
		resource_output, resource_input
	]
	return ship.refinery[property_name]
	
func get_refining_output_efficiency() -> float:
	return ship.refinery["%s_refining_output_efficiency" % resource_output]
	
func update_ui():
	if not visible:
		return
		
	var input_big = get_refining_input_big()
	ui_input_label.text = input_big.toMetricSymbol(true)
	ui_output_label.text = input_big.times(get_refining_output_efficiency()).toMetricSymbol(true)
	
	ui_progress_bar.max_value = 1.0
	ui_progress_bar.value = get_refining_progress() / get_refining_duration()

func _on_check_box_toggled(toggled_on: bool) -> void:
	ship.refinery.active_refining_output = ship.refinery["%s" % resource_output]
