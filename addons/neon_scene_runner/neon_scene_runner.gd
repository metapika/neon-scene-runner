@tool
extends EditorPlugin

const AUTOLOAD_NAME = "App"


func _enable_plugin():
	## Adding the core App script to the Autoload
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/neon_scene_runner/Scripts/Autoload/App.gd")
	if ProjectSettings.has_setting("autoload/App"):
		print("[NeonSceneRunner Addon] Successfully added App to Autoload. Make sure you put all of your Game Scenes in the path you chose and have fun!")

func _disable_plugin():
	## Removing the core App script from the Autoload upon disabling the plugin
	remove_autoload_singleton(AUTOLOAD_NAME)
