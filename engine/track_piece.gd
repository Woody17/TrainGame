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

func positionWithTrack(track: TrackPiece, connection_point: Vector3):
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
	
	var local_our_point = path.curve.get_point_position(0)
	var global_offset = self.position - local_our_point
	self.global_position = track.getTrackPosition(connection_point) + global_offset

	#var offset = track.path.curve.get_closest_offset(connection_point)
	#var points = track.path.curve.tessellate()
	#print(points)
	#print(offset)
	var p1 = track.getTrackPosition(connection_point)
	var offset = track.path.curve.get_closest_offset(p1)
	var multiplier = 1
	var half_length = track.path.curve.get_baked_length() / 2
	if offset < half_length:
		multiplier = -1
	var p2 = track.path.to_global(track.path.curve.sample_baked(offset + (1 * multiplier)))
	
	# Work out a forward vector between p2 and p1
	var direction = p2 - p1
	var normalized_direction = direction.normalized()
	var distance = 2.0
	var new_position = p2 + normalized_direction * distance
	
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
