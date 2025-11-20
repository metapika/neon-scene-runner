@tool
extends EditorPlugin

const AUTOLOAD_NAME = "App"


func _enable_plugin():
	# The autoload can be a scene or script file.
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/neon_scene_runner/Scripts/Autoload/App.gd")

func _disable_plugin():
	remove_autoload_singleton(AUTOLOAD_NAME)
