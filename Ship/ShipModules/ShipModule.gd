class_name ShipModule
extends Node2D

var ship:Ship

func _ready() -> void:
	ship = get_parent() as Ship

func _process(delta: float) -> void:
	if ship == null:
		printerr("Ship is null on ShipModule, did you overide _ready() without calling super._ready()?")
		return
		
	if not ship.intro_played:
		return
	update_stats(delta)
	update_ui()

func update_stats(delta: float) -> void:
	pass
	
func update_ui():
	pass
