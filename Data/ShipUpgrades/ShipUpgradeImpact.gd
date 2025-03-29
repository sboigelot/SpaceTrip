class_name ShipUpgradeImpact
extends Resource

enum IMPACT_METHOD {
	ADD,
	ADD_PERCENT,
	REMOVE,
	REMOVE_PERCENT,
	REPLACE
}

@export var impact_explanation: String
@export var ship_module: String
@export var property_impacted: String
@export var impact_method: IMPACT_METHOD = IMPACT_METHOD.REPLACE
@export var impact_value: float
@export var impact_exponent: int

var _impact_big: Big
var impact_big: Big:
	get():
		if _impact_big == null:
			_impact_big = Big.new(impact_value, impact_exponent)
		return _impact_big
