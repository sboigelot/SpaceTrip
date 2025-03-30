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
	"titanium_per_second_factor": "Titanium mining efficiency"
}

const property_display_suffixes: Dictionary = {
	"engine_auto_boost_cooldown_max": "s",
	"auto_mine_asteroid_count": "",
	"base_acceleration": "m/s/s",
	"engine_boost": "m/s",
	"max_targeted_asteroids": "",
	"max_asteroids": "",
	"engine_boost_duration_max": "s",
	"engine_boost_duration_cooldown_max": "s",
	"titanium_per_second_factor": ""
}

const IMPACT_METHOD_FORMAT: Dictionary = {
	IMPACT_METHOD.ADD: "+%s",
	IMPACT_METHOD.ADD_PERCENT: "+%s%%",
	IMPACT_METHOD.REMOVE: "-%s",
	IMPACT_METHOD.REMOVE_PERCENT: "-%s%%",
	IMPACT_METHOD.REPLACE_BY: "-> %s",
}

enum IMPACT_METHOD {
	ADD,
	ADD_PERCENT,
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
