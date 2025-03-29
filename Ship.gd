class_name Ship
extends Node

#####################
#		EXPORTS		#
#####################

@export_group("UI elements")
@export var ui_shop_container: Container

@export_group("Ship Modules")
@export var core: CoreShipModule
@export var engine: EngineShipModule
@export var mining: MiningShipModule

#####################
#		SIGNALS		#
#####################

signal new_purchase_done(purchase_name)

#####################

var shop_items: Array[ShipUpgrade]
var purchased_items: Array[String]

func _ready() -> void:
	shop_items.assign(ResourceFinder.get_resources_in_folder("res://Data/ShipUpgrades/"))
	
	for shop_item in shop_items:
		var shop_item_view:ShopItemViewBase = shop_item.shop_item_button_view.instantiate()
		shop_item_view.ship = self
		shop_item_view.data = shop_item
		ui_shop_container.add_child(shop_item_view)

func purchase_shop_item(ship_upgrade:ShipUpgrade):
	mining.ore.minusEquals(ship_upgrade.ore_cost)
	
	var module = self
	if ship_upgrade.ship_module != "":
		module = self[ship_upgrade.ship_module]
		assert(module != null)
	
	var property = module[ship_upgrade.property_to_increase]
	assert(property != null)
	if property is Big:
		property.plusEquals(ship_upgrade.increase_value)
	else:
		module[ship_upgrade.property_to_increase] += ship_upgrade.increase_mantissa
	
	var dir_str_length = ship_upgrade.resource_path.rfind("/") + 1
	var purchase_name = ship_upgrade.resource_path.substr(
		dir_str_length,
		ship_upgrade.resource_path.length() - dir_str_length - ".tres".length()
	)
	
	purchased_items.append(purchase_name)
	new_purchase_done.emit(purchase_name)
