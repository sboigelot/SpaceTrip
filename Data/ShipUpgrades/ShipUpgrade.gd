# must set editor/export/convert_text_resources_to_binary to false to load at runtime
class_name ShipUpgrade
extends Resource

@export var debug_hook: bool

@export_group("Description")
@export_multiline var lore_descripton: String

@export_group("Requirements")
@export var parent_purchases: Array[String]
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
		
const shop_item_button_view: PackedScene = preload("res://View/ShipUpgradeButtonView.tscn")

func get_tooltip_content() -> String:
	var impact_descriptions = ""
	for impact in impacts:
		if impact.impact_explanation.length() > 0:
			impact_descriptions += "\n%s" % impact.impact_explanation
		else:
			
			var prop_description:String
			if ShipUpgradeImpact.property_display_names.has(impact.property_impacted):
				prop_description = ShipUpgradeImpact.property_display_names[impact.property_impacted]
			else:
				prop_description = "'%s'" % impact.property_impacted.to_upper()
			
			var prop_suffix: String
			if ShipUpgradeImpact.property_display_suffixes.has(impact.property_impacted):
				prop_suffix = " " + ShipUpgradeImpact.property_display_suffixes[impact.property_impacted]
			
			var value = impact.impact_big.setSmallDecimalsOverride(2)
			if (impact.impact_method in [
				ShipUpgradeImpact.IMPACT_METHOD.ADD_PERCENT,
				ShipUpgradeImpact.IMPACT_METHOD.REMOVE_PERCENT]):
				value = value.times(100)
				value.setSmallDecimalsOverride(0)
				
			impact_descriptions += "\n%s %s%s" % [
				prop_description,
				(ShipUpgradeImpact.IMPACT_METHOD_FORMAT[impact.impact_method] % [
					value.toMetricSymbol(true)
				]),
				prop_suffix
			]
			
	return "[b][u]%s[/u][/b]%s%s" % [
		display_name,
		("\n\t[i]\"%s\"[/i]" % lore_descripton) if lore_descripton.length() > 0 else "",
		impact_descriptions
	]
