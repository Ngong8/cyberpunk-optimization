extends Spatial

var time : float = 0.5
var can_spawn : bool = true
func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("give_spawning"):
		if $Timer.is_stopped():
			$Timer.start(time)
	else:
		if !$Timer.is_stopped():
			$Timer.stop()

const enemies = preload("res://scripts_scenes/Enemy.tscn")
func _on_Timer_timeout() -> void:
	var e = enemies.instance()
	add_child(e)
	print_debug("Spawned enemy.  ",e)
