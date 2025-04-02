class_name ResourcePanel
extends PanelContainer

@export var visible_on_start: bool = false
@export var ui_label: Node

@export var ship: Ship
@export var ship_module: String
@export var property_bound: String

var visible_once: bool = false

func _ready() -> void:
	visible = visible_on_start
	visible_once = visible
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
func _process(delta: float) -> void:
	update_ui()
	
func update_ui():
	
	var property = ship.get_ship_property(ship_module, property_bound)
	
	if property is Big:
		visible = visible_once or property.isGreaterThan(0.0)
		ui_label.text = "%s" % property.setSmallDecimalsOverride(2).toMetricSymbol(true, false)
	else:
		visible = visible_once or property > 0.0
		ui_label.text = "%s" % property
		
	if not visible_once:
		visible_once = visible

func _on_mouse_entered() -> void:
	ship.ui_tooltip.open_and_move(
		property_bound.replace("_", " ").capitalize(), 
		global_position - Vector2(0, size.y), 
		false)

func _on_mouse_exited() -> void:
	ship.ui_tooltip.close()
