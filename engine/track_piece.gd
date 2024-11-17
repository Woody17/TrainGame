extends Node3D

class_name TrackPiece

@export var path: Path3D
@export var area: Area3D

func willEnterTrackPiece():
	pass
	
func willLeaveTrackPiece():
	pass
	
func getAreaRID():
	return area.get_rid()

func getInitialTrackOffset(position: Vector3) -> float:
	position = path.to_local(position)
	return path.curve.get_closest_offset(position)

func getTrackLength() -> float:
	return path.curve.get_baked_length()

func getPositionAtOffset(offset: float) -> Vector3:
	return path.to_global(path.curve.sample_baked(offset))

func getTrackPosition(position: Vector3) -> Vector3:
	var local_pos = path.to_local(position)
	return path.to_global(path.curve.get_closest_point(local_pos))

func getUpTrackPosition(position: Vector3, forward: Vector3) -> Vector3:
	var offset = getInitialTrackOffset(position)
	var upstreamOffset = getInitialTrackOffset(position + (forward * 2))
	return getPositionAtOffset(upstreamOffset)
