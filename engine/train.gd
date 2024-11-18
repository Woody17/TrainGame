extends Node3D

# A train should have 2 wheels and will coordinate the movement
# of the wheels at a given speed
class_name Train

@export var front_wheel: Wheel
@export var back_wheel: Wheel
@export var move_speed: float = 5
@export var train_height: float = 1

var next_transform: Transform3D

func forwardVector() -> Vector3:
	return -global_transform.basis.z.normalized()

func _physics_process(delta: float) -> void:
	# Move both the wheels, then work out the position between
	# the wheels and move us to that point with rotation
	var front_wheel_moved = front_wheel.simulateMovement(delta, move_speed, forwardVector())
	var back_wheel_moved = back_wheel.simulateMovement(delta, move_speed, forwardVector())
	front_wheel.global_position = front_wheel_moved
	back_wheel.global_position = back_wheel_moved
	# Work out the center point
	var center_point = back_wheel_moved.lerp(front_wheel_moved, 0.5) + Vector3(0, train_height / 2, 0);
	global_position = center_point
	# Rotate the train
	# Calculate the direction vector from wheel A to wheel B
	var direction = (front_wheel_moved - back_wheel_moved).normalized()
	# Calculate the angle in radians from the direction vector
	var angle_y = atan2(direction.x, direction.z)
	# Handle slopes
	var height_difference = back_wheel_moved.y - front_wheel_moved.y
	var horizontal_distance = back_wheel_moved.distance_to(front_wheel_moved)
	var angle_x = atan2(height_difference, horizontal_distance)
	global_rotation.y = angle_y
	global_rotation.x = angle_x
	
