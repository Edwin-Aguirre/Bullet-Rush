extends CharacterBody2D


enum EnemyState { Patrolling, Chasing, Searching }


const SPEED: Dictionary[EnemyState, float] = {
	EnemyState.Patrolling: 70.0,
	EnemyState.Chasing: 100.0,
	EnemyState.Searching: 80.0,
}


const FOV: Dictionary[EnemyState, float] = {
	EnemyState.Patrolling: 60.0,
	EnemyState.Chasing: 120.0,
	EnemyState.Searching: 100.0,
}


const BULLET = preload("res://scenes/bullet/bullet.tscn")


@export var patrol_points: NodePath


@onready var nav_agent: NavigationAgent2D = $NavAgent
@onready var debug_label: Label = $DebugLabel
@onready var player_detect: RayCast2D = $PlayerDetect
@onready var gasp_sound: AudioStreamPlayer2D = $GaspSound
@onready var warning: Sprite2D = $Warning
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var shoot_timer: Timer = $ShootTimer
@onready var gun: Marker2D = $Gun
@onready var gun_sound: AudioStreamPlayer2D = $GunSound



var _waypoints: Array[Vector2] = []
var _current_waypoint: int = 0
var _state: EnemyState = EnemyState.Patrolling
var _player_ref: Player


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("set_target"):
		nav_agent.target_position = get_global_mouse_position()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_player_ref = get_tree().get_first_node_in_group(Player.GROUP_NAME)
	if !_player_ref: queue_free()
	create_waypoints()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	detect_player()
	update_behavior()
	update_movement()
	update_raycast()
	set_label()


func create_waypoints() -> void:
	for c in get_node(patrol_points).get_children():
		_waypoints.append(c.global_position)


func navigate_waypoint() -> void:
	if _waypoints.is_empty(): 
		return
	nav_agent.target_position = _waypoints[_current_waypoint]
	_current_waypoint = (_current_waypoint + 1) % _waypoints.size()


func player_is_visible() -> bool:
	return player_detect.get_collider() is Player


func can_see_player() -> bool:
	return abs(get_fov_angle()) < FOV[_state] and player_is_visible()


func get_fov_angle() -> float:
	var dir_to_player: Vector2 = global_position.direction_to(_player_ref.global_position)
	var ang_to_player: float = transform.x.angle_to(dir_to_player)
	return rad_to_deg(ang_to_player)


func update_raycast() -> void:
	player_detect.look_at(_player_ref.global_position)


func update_movement() -> void:
	if nav_agent.is_navigation_finished():
		return
	
	var npp: Vector2 = nav_agent.get_next_path_position()
	rotation = global_position.direction_to(npp).angle()
	#nav_agent.velocity = transform.x * SPEED
	velocity = transform.x * SPEED[_state]
	move_and_slide()


func update_behavior() -> void:
	match  _state:
		EnemyState.Patrolling:
			process_patrolling()
		EnemyState.Chasing:
			process_chasing()
		EnemyState.Searching:
			process_searching()


func set_state(new_state: EnemyState) -> void:
	if new_state == _state: return
	
	if _state == EnemyState.Searching:
		warning.hide()
	
	if new_state == EnemyState.Searching:
		warning.show()
	
	elif new_state == EnemyState.Chasing:
		gasp_sound.play()
		animation_player.play("alert")
	
	elif new_state == EnemyState.Patrolling:
		animation_player.play("RESET")
	
	_state = new_state


func process_patrolling() -> void:
	if nav_agent.is_navigation_finished():
		navigate_waypoint()


func process_chasing() -> void:
	nav_agent.target_position = _player_ref.global_position


func process_searching() -> void:
	if nav_agent.is_navigation_finished():
		set_state(EnemyState.Patrolling)


func detect_player() -> void:
	if can_see_player():
		set_state(EnemyState.Chasing)
	elif  _state == EnemyState.Chasing:
		set_state(EnemyState.Searching)


func set_label() -> void:
	var s: String = ""
	s += "Visible: %s\n" % player_is_visible()
	s += "State: %s\n" % EnemyState.keys()[_state]
	s += "FOV: %.0f\n" % get_fov_angle()
	s += "Can See: %s\n" % can_see_player()
	debug_label.text = s
	debug_label.rotation = -rotation
	


func shoot() -> void:
	if _state != EnemyState.Chasing: return
	var b = BULLET.instantiate()
	b.global_position = gun.global_position
	get_tree().current_scene.call_deferred("add_child", b)
	gun_sound.play()


func _on_nav_agent_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()


func _on_shoot_timer_timeout() -> void:
	shoot()
