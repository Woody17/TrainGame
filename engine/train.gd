extends Node3D

class_name Train

# Params
@export var sampling_delay: int = 10
@export var movement_multiplier: float = 5
@export var train_height: float = 1

# Internal State
var sample_count = 0
var current_track: TrackPiece
# This is a sliding window
var last_track_rids = []
# This is calculated "up the track" based on forward vector
# and can be used for things like rotation
var look_ahead_position: Vector3

# Debugging Helpers
var step_sim = false
var lookAheadNode: Node3D
var currentNode: Node3D

func _enter_tree() -> void:
	lookAheadNode = makeDebugNode()
	currentNode = makeDebugNode()

func _physics_process(delta: float) -> void:
	# Process our simulation
	var newPosition = global_position
	if step_sim:
		if Input.is_action_just_pressed("ForwardSimulation"):
			print("Simulating")
			newPosition = runSimulation(delta)
	else:
		newPosition = runSimulation(delta)
	# Update our train position based on the sim result
	global_position = newPosition
	# Sample if needed
	sampleTrackPiece(delta, newPosition)

# Returns the new position of the train in global coordinates
func runSimulation(delta: float) -> Vector3:
	var newPosition = global_position
	if current_track:
		pass
		# Move
		var moveDir = 1 # Simulate forward
		var forward = forwardVector()
		var move_amount =  (((forward * moveDir) * movement_multiplier) * delta)
		newPosition = newPosition + move_amount
		# Align to track
		newPosition = current_track.getTrackPosition(newPosition) + Vector3(0, train_height / 2, 0)
		# Calculate our "up track" position
		look_ahead_position = current_track.getUpTrackPosition(newPosition, forward)
		# Update rotation
		updateTrainRotation(delta)
		# Update debug
		currentNode.global_position = newPosition
		lookAheadNode.global_position = look_ahead_position
	return newPosition

func forwardVector() -> Vector3:
	return -global_transform.basis.z.normalized()

func updateTrainRotation(delta: float):
	if not global_transform.origin.is_equal_approx(look_ahead_position):
		look_at(look_ahead_position)
		global_rotation.x = 0
		global_rotation.z = 0

func sampleTrackPiece(delta: float, newPosition: Vector3):
	# We (maybe) won't sample for new track every frame
	# It depends on the settings of this train
	if sample_count < sampling_delay:
		sample_count += 1
		return
	sample_count = 0
	# Fire a ray down to find what track piece we are on
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.new()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.hit_from_inside = true
	# We look for the next track an extra move ahead
	query.from = newPosition
	query.to = query.from + Vector3(0, -1, 0)
	# Exclude our recent track
	query.exclude = last_track_rids
	var result = space.intersect_ray(query)
	if result.has_all(["collider"]):
		var area = result["collider"]
		var track = area.get_parent_node_3d()
		if track and track is TrackPiece:
			if current_track != track:
				print("New track piece: ", track)
				var force_forward = false;
				if current_track:
					current_track.willLeaveTrackPiece()
				current_track = track as TrackPiece
				current_track.willEnterTrackPiece()
				recordLastTrackRID(current_track.getAreaRID())

func recordLastTrackRID(rid: RID):
	if last_track_rids.size() > 5:
		last_track_rids.remove_at(0)
	last_track_rids.push_back(rid)

func makeDebugNode() -> Node3D:
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(0.2, 0.2, 0.2)
	mesh.mesh = box
	add_child(mesh)
	return mesh
	
