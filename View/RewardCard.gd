class_name RewardCard
extends PanelContainer

signal pressed(reward_card)

@export var ui_icon_texture_rect: TextureRect
@export var ui_label: Label

var reward: MissionReward

func update_ui():
	ui_icon_texture_rect.texture = reward.icon
	ui_label.text = reward.get_impact_description()

func _on_choose_reward_button_pressed() -> void:
	pressed.emit(self)
