extends Node3D

# Speed of movement and rotation sensitivity
@export var move_speed: float = 5.0
@export var rotation_speed: float = 90.0  # Degrees per second

func _process(delta: float) -> void:
	handle_movement(delta)

func handle_movement(delta: float) -> void:
	# Rotation
	if Input.is_action_pressed("move_left"):
		rotate_y(rotation_speed * delta * deg_to_rad(1))
	if Input.is_action_pressed("move_right"):
		rotate_y(-rotation_speed * delta * deg_to_rad(1))

	# Movement
	var direction: Vector3 = Vector3.ZERO
	if Input.is_action_pressed("move_up"):
		direction += transform.basis.y
	else:
		if Input.is_action_pressed("move_forwards"):
			direction += -transform.basis.z
	if Input.is_action_pressed("move_down"):
		direction += -transform.basis.y
	else:
		if Input.is_action_pressed("move_backwards"):
			direction += transform.basis.z
	
	

	# Normalize and apply movement
	if direction.length() > 0:
		direction = direction.normalized()
		position += direction * move_speed * delta  # Move based on current forward vector
