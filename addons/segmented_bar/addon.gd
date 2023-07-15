@tool
extends EditorPlugin

var icon = preload("res://addons/segmented_bar/assets/icon.png")
var segmented_bar = preload("res://addons/segmented_bar/segmented_bar.gd")


func _enter_tree():
	add_custom_type("SegmentedBar", "HBoxContainer", segmented_bar, icon)


func _exit_tree():
	remove_custom_type("SegmentedBar")
