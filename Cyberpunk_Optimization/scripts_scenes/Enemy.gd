extends KinematicBody
var direction : Vector3; var gravity_vec : Vector3
var velocity : Vector3; var movement : Vector3
export var mov_spd : float = 10.0
export var accel : float = 5.0
export var jump_force : float = 5.0
const gravity : float = 9.8

var on_ground : bool; var can_jump : bool
func apply_gravity(delta: float) -> void:
	if is_on_floor():
		if not on_ground:
#			$JumpTimer.start()
			pass
		gravity_vec = -get_floor_normal()
		on_ground = true
	else:
		can_jump = false
		if on_ground:
			gravity_vec = Vector3()
			on_ground = false
		else:
			gravity_vec += Vector3.DOWN * gravity * delta
	
var target; var self_pos; var panic : bool
enum {NOT_PANIC, PANIC}
var panic_state = NOT_PANIC
func _physics_process(delta: float) -> void:
	self_pos = global_transform.origin
	apply_gravity(delta)
	if target != null:
		if panic_state == NOT_PANIC:
			if self_pos.distance_to(target.global_transform.origin) > 8:
				direction = self_pos.direction_to(target.global_transform.origin)
			else:
				direction = Vector3()
			
			if target.make_panic:
				panic_state = PANIC
		
		elif panic_state == PANIC:
			Panik(delta)
			panic = true
		Looking_Player(target,delta)
	else:
		direction = Vector3()
	
	velocity = velocity.linear_interpolate(direction * mov_spd,accel * delta)
	movement.z = velocity.z + gravity_vec.z
	movement.x = velocity.x + gravity_vec.x
	movement.y = gravity_vec.y
	movement = move_and_slide(movement, Vector3.UP)

var count = 0
func Panik(delta: float) -> void:
	count += 1
	if count > 5 and count < 10:
		$RandomScreams.play()
	
	if self_pos.distance_to(target.global_transform.origin) < 10:
		direction = self_pos.direction_to(-target.global_transform.origin)
	else:
		direction = Vector3()

var looking_rotation = 10
func Looking_Player(look_target,delta: float) -> void:
	var target_position = look_target.global_transform.origin
	var new_transform = global_transform.looking_at(target_position, Vector3.UP)
	global_transform = global_transform.interpolate_with(new_transform, looking_rotation * delta)

func _on_SphericalVision_body_entered(body: Node) -> void:
	if body.name == "Player": target = body

func _on_SphericalVision_body_exited(body: Node) -> void:
	if body.name == "Player": target = null

func _on_VisibilityNotifier_screen_entered() -> void:
	set_physics_process(true)
	$EnemyBody.show(); $Eyes.show()

func _on_VisibilityNotifier_screen_exited() -> void:
	set_physics_process(false)
	$EnemyBody.hide(); $Eyes.hide()
	if panic: queue_free()
