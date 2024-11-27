extends Node3D

# Main coordinator of the entire game play
class_name StateManager

@export var track_container: Node3D
@export var is_editing: bool = true
@export var camera: Camera
@export var play_controls: Controller

enum EditorState {
	NEW_PIECE,
	CONNECTING_PIECE,
	PLACING_PIECE,
	WAITING_FOR_RENDER
}
var state: EditorState = EditorState.NEW_PIECE

@export var editor_camera_move_speed: float = 10

# Internal State
var track_array: Array[TrackPiece] = []
var connection_points: Array[Vector3] = []
var current_connection_index = 0
var connection_gizmo: Node3D
var place_curve: bool = false

var target_camera_position: Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_prepareTrackArray()
	_enterEditMode()

func _enterEditMode():
	state = EditorState.NEW_PIECE
	camera.has_control = false
	play_controls.hide()

func _enterPlayMode():
	camera.has_control = true
	play_controls.show()

func _focusTrackPiece(piece: TrackPiece, instant: bool):
	target_camera_position = Vector3(piece.position.x, 5, piece.position.z)
	if instant:
		camera.position = target_camera_position
	camera.rotation.x= deg_to_rad(-90)

func _processInput(delta: float) -> void:
	var old_index = current_connection_index
	if Input.is_action_just_pressed("move_left"):
		current_connection_index = wrap(current_connection_index - 1, 0, connection_points.size())
	if Input.is_action_just_pressed("move_right"):
		current_connection_index = wrap(current_connection_index + 1, 0, connection_points.size())
	if Input.is_action_just_pressed("action_button"):
		place_curve = Input.is_action_pressed("alternate_action")
		state = EditorState.PLACING_PIECE
	
	if old_index != current_connection_index:
		# Update gizmo
		connection_gizmo.global_position = connection_points[current_connection_index]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_processInput(delta)
	
	camera.position = lerp(camera.position, target_camera_position, editor_camera_move_speed * delta)
	# Process state and changes
	# Don't process until we have one piece
	# We always start with a default piece for now
	if track_array.size() == 0:
		return
	# TODO: Select pieces, delete etc.
	var current_piece = track_array[track_array.size() - 1]
	current_piece.setSelected(true)
	current_piece.updateSelectedState(delta)
	if state == EditorState.NEW_PIECE:
		_focusTrackPiece(current_piece, track_array.size() == 1)
		_processPieceAndPrepareForConnection(current_piece)
		state = EditorState.CONNECTING_PIECE
	if state == EditorState.PLACING_PIECE:
		connection_gizmo.get_parent().remove_child(connection_gizmo)
		# For now, just place a straight
		var piece_name = "res://track/straight.tscn"
		if place_curve:
			piece_name = "res://track/curve.tscn"
		var piece_scene = load(piece_name)
		if not piece_scene:
			state = EditorState.CONNECTING_PIECE
			return
		current_piece.setSelected(false)
		var instance = piece_scene.instantiate() as TrackPiece
		track_container.add_child(instance)
		track_array.push_back(instance)
		instance.positionWithTrack(current_piece, connection_points[current_connection_index])
		#instance.global_position = current_piece.global_position + Vector3(0, 0, -4)
		state = EditorState.NEW_PIECE

func _processPieceAndPrepareForConnection(piece: TrackPiece):
	connection_points = piece.getConnectionPoints()
	assert(connection_points.size())
	# Make a gizmo and position to highlight the connection point
	var mesh = SphereMesh.new()
	mesh.radius = 0.2
	connection_gizmo = MeshInstance3D.new()
	add_child(connection_gizmo)
	connection_gizmo.mesh = mesh
	connection_gizmo.global_position = connection_points[0]
	current_connection_index = 0

func connect_nodes(node_a: Node3D, point_a: Vector3, node_b: Node3D, point_b: Vector3):
	# Get the global position of point_a relative to node_a
	var global_point_a = node_a.global_transform.origin + point_a
	# Set node_b's global position to the calculated position
	node_b.global_transform.origin = global_point_a - point_b
	# Optional: Align node_b's rotation to match node_a's rotation
	node_b.global_transform.basis = node_a.global_transform.basis

func _prepareTrackArray():
	for child in track_container.get_children():
		if child is TrackPiece:
			track_array.push_back(child)
	
