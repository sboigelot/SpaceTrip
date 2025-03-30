# must set editor/export/convert_text_resources_to_binary to false to load at runtime
class_name ShipUpgrade
extends Resource

@export_group("Requirements")
@export var titanium_cost_mantissa: float
@export var titanium_cost_exponent: int
@export var parent_purchases: Array[String]

var _titanium_cost: Big
var titanium_cost: Big:
	get():
		if _titanium_cost == null:
			_titanium_cost = Big.new(titanium_cost_mantissa, titanium_cost_exponent)
		return _titanium_cost
		
@export_group("Impacts")
@export var impacts: Array[ShipUpgradeImpact]

@export_group("Visual")
@export var display_name: String
@export_multiline var lore_descripton: String
@export var shop_item_button_view: PackedScene

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
					value.toMetricSymbol(false)
				]),
				prop_suffix
			]
			
	return "[b][u]%s[/u][/b]%s%s" % [
		display_name,
		("\n\t[i]\"%s\"[/i]" % lore_descripton) if lore_descripton.length() > 0 else "",
		impact_descriptions
	]
