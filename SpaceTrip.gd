class_name Ship
extends Control

#####################
#		EXPORTS		#
#####################

@export_group("UI elements")
@export var ui_distance_label: Label
@export var ui_speed_label: Label
@export var ui_acceleration_label: Label
@export var ui_boost_button: Button
@export var ui_boost_progress: ProgressBar
@export var ui_ore_label: Label
@export var ui_shop_container: Container

#####################
#		SIGNALS		#
#####################

signal new_purchase_done(purchase_name)

#############################
#		SHIP PROPERTIES		#
#############################

@export_group("Ship Properties")

var distance_travelled := Big.ZERO().setSuffixSeparatorOverride(" ")

var speed := Big.ZERO().setSuffixSeparatorOverride(" ")

var base_acceleration := Big.ZERO().setSuffixSeparatorOverride(" ")
var current_acceleration := Big.ZERO().setSuffixSeparatorOverride(" ")
var base_acceleration_drag_factor_per_second: float = 1.0

var engine_boost_duration_max: float = 1.0
var engine_boost_duration_cooldown_max: float = 5.0
var engine_boost_duration_left: float = 0.0
var engine_boost_duration_cooldown: float = 0.0
var engine_boost := Big.ONE().multiplyBy(0.25)
@export var engine_boost_curve: Curve

var boosted_acceleration := Big.ZERO().setSuffixSeparatorOverride(" ")

var ore := Big.ZERO()
var ore_per_asteroid_click := Big.ONE()
var auto_catch_asteroid_chance := 0.0

#############################
#############################

var shop_items: Array[ShipUpgrade]
var purchased_items: Array[String]

func _ready() -> void:
	shop_items.assign(ResourceFinder.get_resources_in_folder("res://Data/ShipUpgrades/"))
	
	for shop_item in shop_items:
		var shop_item_view:ShopItemViewBase = shop_item.shop_item_button_view.instantiate()
		shop_item_view.ship = self
		shop_item_view.data = shop_item
		ui_shop_container.add_child(shop_item_view)

func _process(delta: float) -> void:
	update_stats(delta)
	update_ui()
	
func get_boost_progress() -> float:
	var boost_progress = 1.0 - engine_boost_duration_left / engine_boost_duration_max
	return boost_progress
	
func update_stats(delta: float) -> void:
	
	# calculate current_acceleration with engine boost
	boosted_acceleration = Big.new(base_acceleration)
		
	if engine_boost_duration_left > 0.0:
		engine_boost_duration_left -= delta
		var boost_progress = get_boost_progress()
		var boost_strength = engine_boost_curve.sample(boost_progress)
		var boost = engine_boost.multiplyBy(boost_strength)
		boosted_acceleration.plusEquals(boost)
	elif engine_boost_duration_cooldown > 0.0:
		engine_boost_duration_cooldown -= delta
	
	# add current_acceleration to speed
	if boosted_acceleration.isGreaterThan(0.0):
		speed.plusEquals(boosted_acceleration.multiplyBy(delta))
		
	# drag acceleration --> WARNING NOT TESTED
	if current_acceleration.isGreaterThan(base_acceleration):
		var base_accleration_drag = 1.0 - base_acceleration_drag_factor_per_second * delta
		current_acceleration.multiplyByEquals(base_accleration_drag)
	
	distance_travelled.plusEquals(speed.multiplyBy(delta))
	
	#scrap.plusEquals(Big.multiply(auto_catch_asteroids, delta)) 
	
func update_ui():
	ui_distance_label.text = "Dist: %sm" % distance_travelled.toMetricSymbol(false)
	ui_speed_label.text = "Speed: %sm/s" % speed.toMetricSymbol(false)
	ui_acceleration_label.text = "Acceleration: %sm/s/s" % boosted_acceleration.toMetricSymbol(false)
	ui_boost_button.disabled = engine_boost_duration_cooldown > 0.0
	ui_boost_progress.visible = ui_boost_button.disabled
	if engine_boost_duration_left > 0.0:
		ui_boost_progress.max_value = engine_boost_duration_max
		var boost_progress = get_boost_progress()
		ui_boost_progress.value = (engine_boost_duration_max - engine_boost_duration_left) * boost_progress
		ui_boost_progress.modulate = Color.RED
	elif engine_boost_duration_cooldown > 0.0:
		ui_boost_progress.max_value = engine_boost_duration_cooldown_max
		ui_boost_progress.value = engine_boost_duration_cooldown
		ui_boost_progress.modulate = Color.WHITE
		
	ui_ore_label.text = "Ore: %s" % ore.toMetricSymbol(true)

func purchase_shop_item(ship_upgrade:ShipUpgrade):
	ore.minusEquals(ship_upgrade.ore_cost)
	
	var property = self[ship_upgrade.property_to_increase]
	if property is Big:
		property.plusEquals(ship_upgrade.increase_value)
	else:
		self[ship_upgrade.property_to_increase] += ship_upgrade.increase_mantissa
	
	var dir_str_length = ship_upgrade.resource_path.rfind("/") + 1
	var purchase_name = ship_upgrade.resource_path.substr(
		dir_str_length,
		ship_upgrade.resource_path.length() - dir_str_length - ".tres".length()
	)
	
	purchased_items.append(purchase_name)
	new_purchase_done.emit(purchase_name)
	
func _on_engine_button_pressed() -> void:
	#speed.plusEquals(speed_per_engine_click)
	engine_boost_duration_left = engine_boost_duration_max
	engine_boost_duration_cooldown = engine_boost_duration_cooldown_max
	
func _on_asteroid_button_pressed() -> void:
	#scrap.plusEquals(scrap_per_asteroid_click)
	ore.plusEquals(ore_per_asteroid_click)
