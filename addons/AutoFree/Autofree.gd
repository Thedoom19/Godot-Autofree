@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type(
		"AutoFree",
		"Node",
		preload("res://addons/AutoFree/AutoFreeNode.gd"),
		preload("res://addons/AutoFree/Autofree.svg"),
	)

func _exit_tree() -> void:
	remove_custom_type("AutoFree")
