extends Resource

class_name ShipUpgrade

@export var scrap_cost: float

@export var ship_module_name: String
@export var property_to_increase: String
@export var increase_value: float
@export var increase_is_percent: bool

@export var parent_purchases: Array[String]

@export var shop_item_button_view: PackedScene
