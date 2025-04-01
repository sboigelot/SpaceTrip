class_name MissionView
extends MarginContainer

@export var ui_goal_label: Label
@export var ui_progress_bar: ProgressBar
@export var ui_claim_button: Button
@export var ui_mission_reward_hud: RewardHUD

var ship: Ship
var data: Mission

var completed: bool = false

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
	if completed:
		return
		
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
	ui_claim_button.text = "Claim reward" if data.rewards.size() > 0 else "Complete"

func get_progress_value() -> float:
	var property = ship.get_ship_property(data.goal_module, data.goal_property)
	
	var progress = 0.0
	if property is Big:
		progress = property.dividedBy(data.goal_target_value).toFloat()
	else:
		progress = property / data.goal_target_value.mantissa
	
	return progress

func _process(delta: float) -> void:
	if completed:
		return
		
	check_availability(false)
	update_ui()

func update_ui():
	assert(ship != null)
	assert(data != null)
	
	if not visible or completed:
		return
	
	var progress = get_progress_value()
	ui_progress_bar.value = get_progress_value()
	
	completed = progress >= 1.0
	ui_claim_button.visible = completed
	ui_progress_bar.visible = not completed and data.goal_show_progress
	
	if completed and data.auto_complete:
		complete_and_free()

func _on_mouse_entered() -> void:
	var tooltip_content = data.get_tooltip_content()
	ship.ui_tooltip.open_and_move(
		tooltip_content, 
		global_position + Vector2(0, size.y),
		false)

func _on_mouse_exited() -> void:
	ship.ui_tooltip.close()

func complete_and_free():
	ship.complete_mission(data)
	queue_free()

func _on_claim_button_pressed() -> void:
	if data.rewards.size() == 0:
		complete_and_free()
		return
	
	ui_mission_reward_hud.show_for(self)
	
func _on_reward_claimed(mission_reward: MissionReward):
	ship._apply_ship_upgrade_impact(mission_reward)
	complete_and_free()
