extends Control


var _pickups_count: int = 0
var _collected: int = 0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		GameManager.load_main_scene()


func _ready() -> void:
	SignalHub.on_pickup_collected.connect(on_pickup_collected)
	_pickups_count = get_tree().get_nodes_in_group(Pickup.GROUP_NAME).size()


func on_pickup_collected() -> void:
	_collected += 1
	if _collected == _pickups_count:
		SignalHub.emit_on_show_exit()
