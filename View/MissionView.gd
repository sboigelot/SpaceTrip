class_name MissionView
extends MarginContainer

@export var ui_goal_label: Label
@export var ui_progress_bar: ProgressBar

var ship: Ship
var data: Mission

func _ready() -> void:
	ship.new_purchase_done.connect(on_new_ship_purchase_done)
	ship.new_mission_completed.connect(on_new_mission_completed)
	check_availability(true)
	first_update_ui()
	update_ui()
	
func on_new_ship_purchase_done(purchase_name):
	check_availability(false)
	
func on_new_mission_completed(purchase_name):
	check_availability(false)
	
func check_availability(force_check:bool):
	if not force_check and visible:
		return
		
	if data.has_start_trigger:
		var property = ship.get_ship_property(data.start_trigger_module, data.start_trigger_property)
		
		var triggered = false
		if property is Big:
			triggered = property.isGreaterThanOrEqualTo(data.start_trigger_target_value)
		else:
			triggered = property > data.start_trigger_target_value.mantissa
		
		if not triggered:
			visible = false
			return
		
	for parent_missions in data.parent_missions:
		if not ship.mission_completed.has(parent_missions):
			visible = false
			return
		
	for parent_purchase in data.parent_purchases:
		if not ship.purchased_items.has(parent_purchase):
			visible = false
			return
		
	visible = true
	
func first_update_ui():
	assert(ship != null)
	assert(data != null)
	
	ui_goal_label.text = data.goal_text

func get_progress_value() -> float:
	var property = ship.get_ship_property(data.gloal_module, data.gloal_property)
	
	var progress = 0.0
	if property is Big:
		progress = property.dividedBy(data.gloal_target_value).toFloat()
	else:
		progress = property / data.gloal_target_value.mantissa
	
	return progress

func _process(delta: float) -> void:
	check_availability(false)
	update_ui()

func update_ui():
	assert(ship != null)
	assert(data != null)
	
	if not visible:
		return
	
	var progress = get_progress_value()
	ui_progress_bar.value = get_progress_value()

	if progress >= 1.0:
		ship.complete_mission(data)
		queue_free()
	
func _on_mouse_entered() -> void:
	var tooltip_content = data.get_tooltip_content()
	ship.ui_tooltip.open_and_move(
		tooltip_content, 
		global_position + Vector2(0, size.y),
		false)

func _on_mouse_exited() -> void:
	ship.ui_tooltip.close()
