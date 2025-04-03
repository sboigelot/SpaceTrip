class_name RewardHUD
extends PanelContainer

@export var ui_reward_cards: Array[RewardCard]
var mission_view: MissionView

var time_scale_on_open: float

func _ready() -> void:
	for reward_card in ui_reward_cards:
		reward_card.pressed.connect(_on_reward_card_pressed)

	visible = false

func show_for(_mission_view: MissionView):
	time_scale_on_open = Engine.time_scale
	Engine.time_scale = 0
	mission_view = _mission_view
	update_ui()
	visible = true

func update_ui():
	var mission:Mission = mission_view.data
	for i in ui_reward_cards.size():
		var reward_card = ui_reward_cards[i]
		reward_card.reward = mission.rewards[i % mission.rewards.size()]
		reward_card.update_ui()
	
func _on_reward_card_pressed(reward_card:RewardCard):
	Engine.time_scale = max(1.0, time_scale_on_open)
	mission_view._on_reward_claimed(reward_card.reward)
	visible = false
