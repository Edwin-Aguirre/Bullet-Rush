extends Node


signal on_pickup_collected
signal on_show_exit


func emit_on_pickup_collected() -> void:
	on_pickup_collected.emit()


func emit_on_show_exit() -> void:
	on_show_exit.emit()
