extends Node3D

# The lowest level of a train sim. The wheel simply
# follows the track. By having multiple wheels you can
# determine the current rotation of the train on the track.
# Wheels don't move by themselves but they can run the sim
# and return where they would be positioned
class_name Wheel

@export var showDebugNode: bool = false

# Internal State
# This is a sliding window
var last_track_rids = []

# Debugging Helpers
var debugNode: Node3D

func _enter_tree() -> void:
	if showDebugNode:
		debugNode = makeDebugNode()

func simulateMovement(delta: float, speed: float, forward: Vector3) -> Vector3:
	# Find the track we are on
	var track = sampleTrackPiece(delta)
	if not track:
		# No track, can't move
		return global_position
	var newPosition = global_position
	var move_amount =  ((forward * speed) * delta)
	newPosition = newPosition + move_amount
	# Align to track
	newPosition = track.getTrackPosition(newPosition)
	# Move our debug node now if we have one to show the result
	if debugNode:
		debugNode.global_position = newPosition
	return newPosition

func sampleTrackPiece(delta: float) -> TrackPiece:
	# Fire a ray down to find what track piece we are on
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.new()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.hit_from_inside = true
	# We look for the next track an extra move ahead
	query.from = global_position
	query.to = query.from + Vector3(0, -1, 0)
	# Exclude our recent track
	query.exclude = last_track_rids
	var result = space.intersect_ray(query)
	if result.has_all(["collider"]):
		var area = result["collider"]
		var track = area.get_parent_node_3d()
		if track and track is TrackPiece:
			#recordLastTrackRID(track.getAreaRID())
			return track
	return null

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
	
