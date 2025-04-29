extends CharacterBody2D


class_name Player


const SPEED: float = 150.0
const GROUP_NAME: String = "player"

@onready var player_sprite: Sprite2D = $PlayerSprite


func _enter_tree() -> void:
	add_to_group(GROUP_NAME)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	velocity = movement() * SPEED
	if movement() != Vector2.ZERO:
		rotation = velocity.angle()
	move_and_slide()


func movement() -> Vector2:
	var move: Vector2 = Vector2.ZERO
	move.x = Input.get_axis("left", "right")
	move.y = Input.get_axis("up", "down")
	return move.normalized()
