# must set editor/export/convert_text_resources_to_binary to false to load at runtime
class_name ShipUpgradeImpact
extends Resource

const property_display_names: Dictionary = {
	"engine_auto_boost_cooldown_max": "Auto engine boost",
	"auto_mine_asteroid_count": "Auto mining laser",
	"base_acceleration": "Base acceleration",
	"engine_boost": "Engine boost strength",
	"max_targeted_asteroids": "Maximum mining laser",
	"max_asteroids": "Maximum asteroid",
	"engine_boost_duration_max": "Engine boost duration",
	"engine_boost_duration_cooldown_max": "Engine boost cooldown",
	"titanium_per_second_factor": "Titanium mining speed",
	"plate_refining_duration": "Plate refining duration",
	"plate_refining_input_titanium": "Plate refining input",
	"plate_refining_output_efficiency": "Plate refining efficiency",
	"liquid_fuel_refining_duration": "Liquid fuel refining duration",
	"liquid_fuel_refining_input_carbon": "Liquid fuel refining input",
	"liquid_fuel_refining_output_efficiency": "Liquid fuel refining efficiency",
	"asteroid_spawn_titanium_chance": "Chance of titanium asteroid",
	"asteroid_spawn_carbon_chance": "Chance of carbon asteroid",
	"asteroid_spawn_warter_chance": "Chance of water asteroid",
	"asteroid_spawn_palladium_chance": "Chance of palladium asteroid",
	"asteroid_spawn_pyralium_chance": "Chance of pyralium asteroid",
	"dimension_index": "Travel dimension",
	"global_mining_speed_factor": "General mining speed",
	"carbon_per_second_factor": "Carbon mining speed",
	"water_per_second_factor": "Water mining speed",
	"asteroid_spawn_water_chance": "Chance of water asteroid",
	"hydrogen_refining_duration": "Hydrogen refining duration",
	"hydrogen_refining_input_water": "Hydrogen refining input",
	"hydrogen_refining_output_efficiency": "Hydrogen refining efficiency",
	"plate_refining_passive_factor": "Passive plate refining speed",
	"liquid_fuel_refining_passive_factor": "Passive liquid fuel refining speed",
	"global_scanning_frequency_factor": "Asteroid discovery speed",
	"asteroid_spawn_min_mining_time_available": "Min asteroid resource content",
	"asteroid_spawn_max_mining_time_available": "Max asteroid resource content",
	"global_refinery_speed_factor": "Global refinery speed",
}

const property_display_suffixes: Dictionary = {
	"engine_auto_boost_cooldown_max": "s",
	"base_acceleration": "m/s/s",
	"engine_boost": "m/s",
	"engine_boost_duration_max": "s",
	"engine_boost_duration_cooldown_max": "s",
	"plate_refining_duration": "s",
	"plate_refining_input_titanium": "titanium",
	"liquid_fuelrefining_duration": "s",
	"liquid_fuel_refining_input_carbon": "carbon",
	"hydrogen_refining_duration": "s",
	"hydrogen_refining_input_water": "water",
}

const IMPACT_METHOD_FORMAT: Dictionary = {
	IMPACT_METHOD.ADD: "+ %s",
	IMPACT_METHOD.MULTIPLY_BY: "x %s",
	IMPACT_METHOD.REMOVE: "- %s",
	IMPACT_METHOD.REMOVE_PERCENT: "- %s%%",
	IMPACT_METHOD.REPLACE_BY: "-> %s",
}

enum IMPACT_METHOD {
	ADD,
	MULTIPLY_BY,
	REMOVE,
	REMOVE_PERCENT,
	REPLACE_BY
}

@export var impact_explanation: String
@export var ship_module: String
@export var property_impacted: String
@export var impact_method: IMPACT_METHOD = IMPACT_METHOD.REPLACE_BY
@export var impact_value: float
@export var impact_exponent: int

var _impact_big: Big
var impact_big: Big:
	get():
		if _impact_big == null:
			_impact_big = Big.new(impact_value, impact_exponent)
		return _impact_big

func get_impact_description() -> String:
	if impact_explanation.length() > 0:
		return impact_explanation
	
	var prop_description:String
	if property_display_names.has(property_impacted):
		prop_description = property_display_names[property_impacted]
	else:
		prop_description = "%s" % property_impacted.replace("_", " ").capitalize()
	
	var prop_suffix: String
	if ShipUpgradeImpact.property_display_suffixes.has(property_impacted):
		prop_suffix = " " + property_display_suffixes[property_impacted]
	
	var value = impact_big.setSmallDecimalsOverride(2)
	if (impact_method == IMPACT_METHOD.REMOVE_PERCENT):
		value = value.times(100)
		value.setSmallDecimalsOverride(0)
		
	var impact_description = "%s %s%s" % [
			prop_description,
			(ShipUpgradeImpact.IMPACT_METHOD_FORMAT[impact_method] % [
				value.toMetricSymbol(false, true)
			]),
			prop_suffix
		]
	return impact_description
