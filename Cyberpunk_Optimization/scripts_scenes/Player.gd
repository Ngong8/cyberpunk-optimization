extends KinematicBody
var direction : Vector3; var gravity_vec : Vector3
var velocity : Vector3; var movement : Vector3
export var mov_spd : float = 10.0
export var accel : float = 5.0
export var jump_force : float = 5.0
const gravity : float = 9.8

var can_show_help : bool
var can_see_mouse : bool; var can_shoot : bool = true
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	can_see_mouse = false; can_show_help = true

export(float,0.01,5.0) var mouse_sen = 0.25
onready var head = $Head
func _input(event: InputEvent) -> void:
	if !can_see_mouse:
		if event is InputEventMouseMotion:
			rotation_degrees.y -= event.relative.x * mouse_sen
			head.rotation_degrees.x = clamp(head.rotation_degrees.x - event.relative.y * mouse_sen, -80, 80)
	
	if Input.is_action_just_pressed("ui_cancel"):
		if !can_see_mouse:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			can_see_mouse = true
		elif can_see_mouse:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			can_see_mouse = false
	
	if Input.is_action_just_pressed("give_help"):
		can_show_help = !can_show_help
	
	direction = Vector3()
	walk()

func walk() -> void:
	if Input.is_key_pressed(KEY_W): direction.z = -1
	elif Input.is_key_pressed(KEY_S): direction.z = 1
	if Input.is_key_pressed(KEY_A): direction.x = -1
	elif Input.is_key_pressed(KEY_D): direction.x = 1
	direction = direction.normalized()
	direction = direction.rotated(Vector3.UP, rotation.y)

var on_ground : bool; var can_jump : bool
func apply_gravity(delta: float) -> void: # Check if you're on ground or airborne to apply gravity!
	if is_on_floor():
		if not on_ground:
			$JumpTimer.start()
		gravity_vec = -get_floor_normal()
		on_ground = true
	else:
		can_jump = false
		if on_ground:
			gravity_vec = Vector3()
			on_ground = false
		else:
			gravity_vec += Vector3.DOWN * gravity * delta
	if Input.is_key_pressed(KEY_SPACE):
		if is_on_floor() and can_jump:
			jump()
	
func jump() -> void:
	on_ground = false
	gravity_vec = Vector3.UP * jump_force

func _on_JumpTimer_timeout() -> void:
	can_jump = true

var make_panic : bool
onready var timeSlider = $Control/SliderPanel/TimerSlider
onready var CurrentTimeLabel = $Control/SliderPanel/CurrentTimeLabel
onready var helpPanel = $Control/HelpPanel
onready var sliderPenel = $Control/SliderPanel
var current_spd = mov_spd; var sprint_spd = mov_spd * 2
func _physics_process(delta: float) -> void:
	if can_show_help: helpPanel.show()
	elif !can_show_help: helpPanel.hide()
	if can_see_mouse: sliderPenel.show()
	elif !can_see_mouse: sliderPenel.hide()
	# Shooting 'mechanic'...
	if can_shoot && !can_see_mouse:
		if Input.is_action_pressed("shoot"):
			print_debug("Fire weapon! You should panic!")
			$Head/GunAnim.play("Shooting")
			$Head/RifleSound.play(0.05)
			$ShootTimer.start(0.15)
			can_shoot = false
			make_panic = true
	
	# Gravity and movement vectors...
	if Input.is_key_pressed(KEY_SHIFT): current_spd = sprint_spd
	else: current_spd = mov_spd
	
	apply_gravity(delta)
	velocity = velocity.linear_interpolate(direction * current_spd,accel * delta)
	movement.z = velocity.z + gravity_vec.z
	movement.x = velocity.x + gravity_vec.x
	movement.y = gravity_vec.y
	movement = move_and_slide(movement, Vector3.UP)
	
	var Spawners = get_tree().get_nodes_in_group("Spawners")
	for s in Spawners:
		s.time = timeSlider.value
	CurrentTimeLabel.set_text("Current Time(s) : %.1f" %[timeSlider.value])

func _on_ShootTimer_timeout() -> void:
	can_shoot = true
	make_panic = false

