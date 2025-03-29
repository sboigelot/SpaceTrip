class_name ShipUpgrade
extends Resource

@export_group("Requirements")
@export var ship_module_name: String
@export var parent_purchases: Array[String]
@export var scrap_cost_mantissa: float
@export var scrap_cost_exponent: int

var _scrap_cost: Big
var scrap_cost: Big:
	get():
		if _scrap_cost == null:
			_scrap_cost = Big.new(scrap_cost_mantissa, scrap_cost_exponent)
		return _scrap_cost
		
@export_group("Impact")
@export var property_to_increase: String
@export var increase_mantissa: float
@export var increase_exponent: int
@export var increase_is_percent: bool

var _increase_value: Big
var increase_value: Big:
	get():
		if _increase_value == null:
			_increase_value = Big.new(increase_mantissa, increase_exponent)
		return _increase_value

@export_group("Visual")
@export var shop_item_button_view: PackedScene
