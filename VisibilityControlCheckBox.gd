@tool
class_name VisibilityControlCheckBox
extends CheckBox

@export var target: CanvasItem

func _ready() -> void:
	pressed.connect(_on_pressed)
	
func _on_pressed():
	if target == null:
		return
		
	target.visible = button_pressed
