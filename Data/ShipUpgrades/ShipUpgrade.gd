# must set editor/export/convert_text_resources_to_binary to false to load at runtime
class_name ShipUpgrade
extends Resource

@export var debug_hook: bool

@export_group("Description")
@export_multiline var lore_descripton: String

@export_group("Requirements")
@export var parent_purchases: Array[String]
@export var parent_missions: Array[String]
@export var titanium_cost: Big
@export var plate_cost: Big
@export var carbon_cost: Big
@export var liquid_fuel_cost: Big
@export var water_cost: Big
@export var hydrogen_cost: Big
@export var palladium_cost: Big
@export var electronic_cost: Big
@export var pyralium_cost: Big
@export var mana_cost: Big
		
@export_group("Impacts")
@export var impacts: Array[ShipUpgradeImpact]

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
		
var is_free: bool:
	get():
		return (
			titanium_cost == null and
			plate_cost == null and
			carbon_cost == null and
			liquid_fuel_cost == null and
			water_cost == null and
			hydrogen_cost == null and
			palladium_cost == null and
			electronic_cost == null and
			pyralium_cost == null and
			mana_cost == null
		)
		
const shop_item_button_view: PackedScene = preload("res://View/ShipUpgradeButtonView.tscn")

func get_tooltip_content() -> String:
	var impact_descriptions = ""
	for impact in impacts:
		impact_descriptions += "\n%s"  % impact.get_impact_description()
			
	return "[b][u]%s[/u][/b]%s%s" % [
		display_name,
		("\n\t[i]\"%s\"[/i]" % lore_descripton) if lore_descripton.length() > 0 else "",
		impact_descriptions
	]
