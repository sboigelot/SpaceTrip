extends Control

class_name Ship

@export var ui_distance_label: Label
@export var ui_speed_label: Label
@export var ui_scrap_label: Label
@export var ui_shop_container: Container

signal new_purchase_done(purchase_name)

var distance_travelled := Big.ZERO()
var distance_per_engine_click := Big.ONE()
var base_speed := Big.ZERO()
var speed := Big.ZERO()
var speed_per_engine_click := Big.ONE()
var speed_drag :float = 0.5
var scrap := Big.ZERO()
var scrap_per_asteroid_click := Big.ONE()
var auto_catch_asteroids := Big.ZERO()

var shop_items: Array[ShipUpgrade]
var purchased_items: Array[String]

func _ready() -> void:
	shop_items.assign(ResourceFinder.get_resources_in_folder("res://Data/"))
	
	for shop_item in shop_items:
		var shop_item_view:ShopItemViewBase = shop_item.shop_item_button_view.instantiate()
		shop_item_view.ship = self
		shop_item_view.data = shop_item
		ui_shop_container.add_child(shop_item_view)

func _process(delta: float) -> void:
	update_stats(delta)
	update_ui()
	
func update_stats(delta: float) -> void:
	distance_travelled.plusEquals(Big.multiply(speed, delta))
	
	speed = Big.maxValue(base_speed, speed.minusEquals(
		Big.multiply(speed_drag * delta, Big.maxValue(0.0, speed.minus(base_speed)))
	))
	
	scrap.plusEquals(Big.multiply(auto_catch_asteroids, delta)) 
	
func update_ui():
	ui_distance_label.text = "Dist: %sm" % distance_travelled.toMetricSymbol(true)
	ui_speed_label.text = "Speed: %sm/s" % speed.toMetricSymbol(false)
	ui_scrap_label.text = "Scrap: %s" % scrap.toMetricSymbol(true)

func purchase_shop_item(ship_upgrade:ShipUpgrade):
	scrap.minusEquals(ship_upgrade.scrap_cost)
	self[ship_upgrade.property_to_increase].plusEquals(ship_upgrade.increase_value)
	
	var dir_str_length = ship_upgrade.resource_path.rfind("/") + 1
	var purchase_name = ship_upgrade.resource_path.substr(
		dir_str_length,
		ship_upgrade.resource_path.length() - dir_str_length - ".tres".length()
	)
	
	purchased_items.append(purchase_name)
	new_purchase_done.emit(purchase_name)
	
func _on_engine_button_pressed() -> void:
	speed.plusEquals(speed_per_engine_click)
	
func _on_asteroid_button_pressed() -> void:
	scrap.plusEquals(scrap_per_asteroid_click)
