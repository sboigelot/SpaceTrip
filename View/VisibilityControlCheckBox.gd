@tool
class_name VisibilityControlCheckBox
extends CheckBox

@export var target: CanvasItem
@export var override_method: String = ""

func _ready() -> void:
	pressed.connect(_on_pressed)
	
func _on_pressed():
	if target == null:
		return
		
	if override_method == "":
		target.visible = button_pressed
	else:
		target.callv(override_method, [button_pressed])
