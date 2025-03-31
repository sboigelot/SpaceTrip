class_name RefineryHUD
extends PanelContainer

@export var ship: Ship
@export var process_container: Container

func _ready() -> void:
	ship.new_purchase_done.connect(_on_ship_new_purchase_done)
	update_ui()

func _on_ship_new_purchase_done(purchase_name):
	update_ui()

func update_ui():
	visible = false
	
	for process in process_container.get_children():
		process.check_unlocked()
		if process.visible:
			visible = true
