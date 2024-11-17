extends Node3D

class_name Train

# Params
@export var sampling_delay: int = 0
@export var movement_multiplier: float = 0.1
@export var train_height: float = 1
@export var debug_node: Node3D

# Internal State
var sample_count = 0
var current_track: TrackPiece
# This is a sliding window
var last_track_rids = []
var current_track_offset = 0
var backwards_piece = false

func _physics_process(delta: float) -> void:
	# Process our current piece, move us along in the simulation
	var newPosition = global_position
	if current_track:
		pass
		# Move
		var moveDir = 1
		if backwards_piece:
			moveDir = -1
		current_track_offset += ((moveDir * movement_multiplier) * delta)
		# Align to track
		newPosition = current_track.getPositionAtOffset(current_track_offset) + Vector3(0, train_height / 2, 0)
		look_at(newPosition, Vector3.UP)
		global_position = newPosition
	# We don't sample for new track every frame
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
	debug_node.global_position = query.to
	# Exclude our recent track
	query.exclude = last_track_rids
	var result = space.intersect_ray(query)
	if result.has_all(["collider"]):
		var area = result["collider"]
		var track = area.get_parent_node_3d()
		if track and track is TrackPiece:
			if current_track != track:
				if current_track:
					current_track.willLeaveTrackPiece()
				current_track = track as TrackPiece
				current_track.willEnterTrackPiece()
				current_track_offset = current_track.getInitialTrackOffset(global_position)
				backwards_piece = current_track_offset > current_track.getTrackLength() / 2
				recordLastTrackRID(current_track.getAreaRID())
				
func recordLastTrackRID(rid: RID):
	if last_track_rids.size() > 5:
		last_track_rids.remove_at(0)
	last_track_rids.push_back(rid)
	
