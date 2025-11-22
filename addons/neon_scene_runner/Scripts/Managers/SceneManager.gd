extends Node

## Path for the script to look for GameScenes
@export var _game_scenes_path = "Scenes/GameScenes"
@export var _force_wait_loading = 2.0
@export var _debug_mode = false
@onready var _app = get_tree().root.get_node("App")

## Dictionary for storing initialized Scene Resources
var _game_scenes = { }

## Reference for the currently loaded scene
var _current_scene_name = "NONAME"

## All Currently loaded Scenes
#var loaded_scenes = []

## Loading screen UI object reference
var _loading_screen = null

## Signals produced by the SceneManager script
signal _scene_initialized(_scene_name)
signal _scene_unloaded(_scene_name)

## Debug-only functions
func _debug_message(msg : String, error : bool = false):
	if error:
		assert(false, "[NeonSceneRunner Addon Error] " + msg)
		return

	if _debug_mode:
		print( "[NeonSceneRunner Addon] " + msg)

## Initialize Scene Resource Files
func _ready() -> void:
	## Find loading screen reference
	if _app._page_controller != null:
		## TODO: PAGE CONTROLLER INTEGRATION
		pass
	else:
		_loading_screen = %UI.get_node("LoadingScreen")
		
	## Example of connecting SceneManager signals to get info about scene changes
	_scene_initialized.connect(_on_scene_loaded)
	_scene_unloaded.connect(_on_scene_unloaded)

## Add all GameScenes to the Dictionary
func _find_all_game_scenes():
	var dir = DirAccess.open("res://" + _game_scenes_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.right(5) == ".tscn":
				## File that was found is a Scene file, adding it to the Game Scene List
				_game_scenes[file_name.trim_suffix(".tscn")] = "res://" + _game_scenes_path + '/' + file_name
				_debug_message("Successfully added scene: " + file_name)
			else:
				_debug_message("File \"%s\" isn't a Scene file. Skipping.." % [file_name])
			
			file_name = dir.get_next()
	else:
		_debug_message("Error trying to initialize Scenes. Does the directory res://%s exist?" % [_game_scenes_path], true)

## Function that finds the scene that the user pressed F6 on
func _find_init_scene(_init_scene : Node):
	for i in range(len(_game_scenes)):
		if _game_scenes.keys()[i] == _init_scene.name:
			_debug_message("Found the initial scene.")
			_current_scene_name = _init_scene.name
			_on_scene_loaded(_current_scene_name)
			return
	
	_debug_message("Could not find init scene. Did you add the Scene you F6-d to the res://%s directory? (Continuing anyway..)" % _game_scenes_path)

## Scene reference functions
func _get_scene_path_by_name(_scene_name : String):
	return _game_scenes[_scene_name]

func _get_scene_index_by_name(_scene_name : String):
	for i in range(len(_game_scenes)):
		if _game_scenes.keys()[i] == _scene_name:
			return i

func _get_scene_name_by_index(_scene_index : int):
	if _scene_index < 0 or _scene_index > len(_game_scenes):
		_debug_message("Invalid Scene index, please enter an index in the range: (0;%d)" % [len(_game_scenes) - 1], true)
		return -1
	
	return _game_scenes.keys()[_scene_index]

func _get_scene_path_by_index(_scene_index : int):
	if _scene_index < 0 or _scene_index > len(_game_scenes):
		_debug_message("Invalid Scene index, please enter an index in the range: (0;%d)" % [len(_game_scenes) - 1], true)
		return -1
	
	return _game_scenes.values()[_scene_index]
	
## Scene loading management functions
func _change_scene(_scene_name : String, _show_loading_screen = true):
	if _current_scene_name == _scene_name:
		_debug_message("You tried to load the same scene. Aborting..")
		return
	
	if !(_scene_name in _game_scenes.keys()):
		_debug_message("The scene you tried to change to (%s) is not present in the GameScenes folder. Please make sure the scene you want to change to is in res://%s" % [_scene_name, _game_scenes_path], true)
		return
	
	## Current scenes are always the first childo of the _scene_holder Node
	var _current_scene_node = _app._scene_holder.get_child(0)

	if _show_loading_screen and _loading_screen:
		## Checks if NeonPageController exists
		if _app._page_controller != null:
			## TODO: PAGE CONTROLLER INTEGRATION
			pass
		else:
			_loading_screen.visible = true
	elif _show_loading_screen and !_loading_screen:
		_debug_message("Could not find the LoadingScreen UI object reference. Are you sure it exists?", true)
		
	get_tree().paused = true
	
	var _prev_scene_name = _current_scene_name
	var _new_scene = _load_scene(_scene_name)

	## Emit the _scene_initalized signal
	await get_tree().process_frame
	_scene_initialized.emit(_current_scene_name)

	## Wait a little bit more to show off the beautiful Loading Screen you've made!
	if _show_loading_screen:
		await get_tree().create_timer(_force_wait_loading).timeout
	
	get_tree().paused = false
	_current_scene_node.queue_free()
	_scene_unloaded.emit(_prev_scene_name)
	
	_loading_screen.visible = false
	_new_scene.reparent(_app._scene_holder)
	
	_debug_message("Successfully changed to scene: \"%s\"" % [_scene_name])

## Main loading scene function
func _load_scene(_scene_name : String):
	var _scene_path = _get_scene_path_by_name(_scene_name)
	
	_debug_message("Loading scene: %s" % [_scene_name])
	
	## Instantiate desired scene
	var _loaded_scene = load(_scene_path).instantiate()
	add_child(_loaded_scene)
	
	_current_scene_name = _scene_name
	
	return _loaded_scene

## Alternative index-based loading function
func _load_scene_by_index(_scene_index : int):
	_load_scene(_game_scenes[_game_scenes.keys()[_scene_index]])

## Debug functions for testing SceneManager signals
func _on_scene_loaded(_new_scene_name):
	_debug_message("Initialized Scene: %s (Index: %d)" % [_new_scene_name, _get_scene_index_by_name(_new_scene_name)])

func _on_scene_unloaded(_unloaded_scene_name):
	_debug_message("Scene \"%s\" (Index: %d) has been unloaded." % [_unloaded_scene_name, _get_scene_index_by_name(_unloaded_scene_name)])
