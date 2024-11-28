extends Node3D

class_name TrackPiece

@export var path: Path3D
@export var area: Area3D

const MIN_SCALE: float = 0.8
const MAX_SCALE: float = 1.0
var pulse_speed: float = 1.0
var time: float = 0.0

func getAreaRID():
	return area.get_rid()

func getTrackPosition(p: Vector3) -> Vector3:
	var local_pos = path.to_local(p)
	return getLocalTrackPosition(local_pos)

func getLocalTrackPosition(p: Vector3) -> Vector3:
	return path.to_global(path.curve.get_closest_point(p))

func getConnectionPoints() -> Array[Vector3]:
	var points: Array[Vector3] = []
	for i in range(path.curve.point_count):
		points.push_back(path.to_global(path.curve.get_point_position(i)))
	return points

func setSelected(selected: bool):
	if not selected:
		self.scale = Vector3.ONE

func updateSelectedState(delta: float):
	time += pulse_speed * delta
	var scale_factor = MIN_SCALE + (MAX_SCALE - MIN_SCALE) * (0.5 * (sin(time * PI * 2) + 1))
	scale = Vector3(scale_factor, scale_factor, scale_factor)
	

func angle_to_clockwise_3d(from: Vector3, to: Vector3, axis: Vector3 = Vector3(0, 1, 0)) -> float:
	# Normalize both vectors to ensure correct results
	var from_normalized = from.normalized()
	var to_normalized = to.normalized()
	
	# Calculate the angle between the two vectors using the dot product
	var dot = from_normalized.dot(to_normalized)
	var angle = acos(dot)  # This gives the smallest angle between the two vectors
	
	# Use the cross product to determine the direction of rotation
	var cross = from_normalized.cross(to_normalized)
	
	# Check if the cross product points in the positive or negative direction along the axis
	if cross.dot(axis) < 0:
		angle = -angle  # If the cross product points in the opposite direction, reverse the angle
	
	return angle

func positionWithTrack(track: TrackPiece, connection_point: Vector3) -> Vector3:
	#var our_connection_point = getConnectionPoints()[0]
	## Work out the expected rotation
	#var offset = Vector3(1, 1, 1)
	#var point_before = track.getLocalTrackPosition(connection_point - offset)
	#var point_after = track.getLocalTrackPosition(connection_point + offset)
	#var to_connect_direction = (point_after - point_before).normalized()
	#point_before = getLocalTrackPosition(our_connection_point - offset)
	#point_after = getLocalTrackPosition(our_connection_point + offset)
	#var our_connect_direction = (point_after - point_before).normalized()
	#print(to_connect_direction)
	#print(our_connect_direction)
	#print(to_connect_direction.angle_to(our_connection_point))
	#self.rotation.y = to_connect_direction.angle_to(our_connection_point)
	#print(rad_to_deg(self.rotation.y))
	
	self.global_position = track.getTrackPosition(connection_point)

	#var offset = track.path.curve.get_closest_offset(connection_point)
	#var points = track.path.curve.tessellate()
	#print(points)
	#print(offset)
	var p1 = track.getTrackPosition(connection_point)
	var offset = track.path.curve.get_closest_offset(p1)
	var half_length = track.path.curve.get_baked_length() / 2
	var multiplier = -1
	var p2 = track.path.to_global(track.path.curve.sample_baked(offset + (1 * multiplier)))
	
	# Work out a forward vector between p2 and p1
	var direction = p2 - p1
	var normalized_direction = direction.normalized()
	#var angle = angle_to_clockwise_3d(normalized_direction, Vector3(1, 0, 0), Vector3.UP)
	var angle = normalized_direction.angle_to(Vector3(1, 0, 0))
	
	var distance = -2.0
	var new_position = p1 + normalized_direction * distance
	
	look_at(new_position)
	global_rotation.x = 0
	global_rotation.z = 0
	
	
	var d1 = Debug.makeDebugNode(0.2, Color.GREEN)
	var d2 = Debug.makeDebugNode(0.2, Color.BLUE)
	var d3 = Debug.makeDebugNode(0.2, Color.MAGENTA)
	add_child(d1)
	add_child(d2)
	add_child(d3)
	d1.global_position = p1
	d2.global_position = p2
	d3.global_position = new_position
	
	return getConnectionPoints()[0]

func get_curve_direction_at_end() -> Vector3:
	# Returns the direction vector at the end of the curve (tangent) normalized.
	var point_count = path.curve.get_point_count()
	# If there's only one point, we can't compute a tangent (avoid out-of-bounds access)
	if point_count < 2:
		return Vector3.ZERO
	# Get the last two points on the curve
	var last_point = path.curve.get_point_position(point_count - 1)
	var second_last_point = path.curve.get_point_position(point_count - 2)
	# Calculate the tangent (direction) by subtracting the second-to-last point from the last point
	var tangent = last_point - second_last_point
	return tangent.normalized()  # Normalize the tangent to get the direction

# Function to align the new track piece with the previous piece's end direction
func align_with_previous_piece(previous_piece: TrackPiece):
	# Get the direction at the end of the previous track piece
	var previous_direction = previous_piece.get_curve_direction_at_end()

	# Get the connection points (start and end) of the new piece and the previous piece
	var prev_connection_points = previous_piece.getConnectionPoints()
	var new_connection_points = self.getConnectionPoints()

	# Get the global position of the new piece (starting pivot point)
	var new_start_point = new_connection_points[0] # Start point of the new piece
	var prev_end_point = prev_connection_points[1] # End point of the previous piece
	
	# Calculate the offset between the connection points
	var offset = prev_end_point - new_start_point
	
	# Align the new piece to the direction of the previous piece's curve direction
	var angle = previous_direction.angle_to(Vector3(1, 0, 0))  # Angle from X-axis to direction vector
	var axis_of_rotation = previous_direction.cross(Vector3(1, 0, 0)).normalized()  # Axis of rotation
	
	# Rotate the new piece based on the angle and axis
	var euler_rotation = Vector3()  # Rotation vector as Euler angles (pitch, yaw, roll)
	if axis_of_rotation == Vector3(0, 1, 0):  # Check if rotation is around the Y-axis
		euler_rotation.y = angle  # Rotate around the Y-axis
	elif axis_of_rotation == Vector3(0, 0, 1):  # Rotation around Z-axis
		euler_rotation.z = angle
	elif axis_of_rotation == Vector3(1, 0, 0):  # Rotation around X-axis
		euler_rotation.x = angle
	
	# Apply the Euler angle rotation to the new piece
	self.rotation = euler_rotation
	
	# Now, position the new piece to align with the previous piece's end point
	self.global_position = previous_piece.global_position + offset
