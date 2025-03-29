class_name ShipUpgrade
extends Resource

@export_group("Requirements")

@export var ship_module: String
@export var titanium_cost_mantissa: float
@export var titanium_cost_exponent: int
@export var parent_purchases: Array[String]

var _titanium_cost: Big
var titanium_cost: Big:
	get():
		if _titanium_cost == null:
			_titanium_cost = Big.new(titanium_cost_mantissa, titanium_cost_exponent)
		return _titanium_cost
		
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
