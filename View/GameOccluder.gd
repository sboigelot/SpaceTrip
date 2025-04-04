class_name VisibleIfAnyOtherVisibleColorRect
extends ColorRect

@export var other_nodes: Array[Node]

func _process(delta: float) -> void:
	for other_node in other_nodes:
		if not other_node.visible:
			visible = false
			return
	visible = true
		
