extends Area2D


class_name Pickup


const GROUP_NAME: String = "Pickup"


@onready var sound: AudioStreamPlayer2D = $Sound


func _enter_tree() -> void:
	add_to_group(GROUP_NAME)


func _on_body_entered(_body: Node2D) -> void:
	set_deferred("monitoring", false)
	hide()
	sound.play()
	SignalHub.emit_on_pickup_collected()


func _on_sound_finished() -> void:
	queue_free()
