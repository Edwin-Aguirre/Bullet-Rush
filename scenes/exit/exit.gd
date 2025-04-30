extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	SignalHub.on_show_exit.connect(on_show_exit)


func on_show_exit() -> void:
	set_deferred("monitoring", true)
	show()
