# must set editor/export/convert_text_resources_to_binary to false to load at runtime
class_name Mission
extends Resource

const mission_view: PackedScene = preload("res://View/MissionView.tscn")

@export_group("Description")
@export_multiline var lore_descripton: String

@export_group("Start Trigger", "start_trigger_") 
@export var start_trigger_module: String
@export var start_trigger_property: String
@export var start_trigger_target_value: Big = Big.ZERO()

@export_group("Start Requirements", "parent_")
@export var parent_missions: Array[String]
@export var parent_purchases: Array[String]

@export_group("Goal", "goal_")
@export var goal_show_progress: bool = true
@export var goal_text: String
@export var goal_module: String
@export var goal_property: String
@export var goal_target_value: Big = Big.ZERO()

@export_group("Rewards")
@export var auto_complete: bool = false
@export var rewards: Array[MissionReward]

var _display_name:String
var display_name: String:
	get():
		if _display_name != "":
			return _display_name
			
		var dir_str_length = resource_path.rfind("/") + 1
		_display_name = resource_path.substr(
			dir_str_length,
			resource_path.length() - dir_str_length - ".tres".length()
		)
		return _display_name
	set(value):
		_display_name = value

var has_start_trigger: bool:
	get():
		return start_trigger_module != "" and start_trigger_property != ""
		
func get_tooltip_content() -> String:
	return "[b][u]%s[/u][/b]%s" % [
		goal_text,
		("\n\t[i]\"%s\"[/i]" % lore_descripton) if lore_descripton.length() > 0 else ""
	]
	
