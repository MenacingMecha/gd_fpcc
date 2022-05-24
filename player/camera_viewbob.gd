extends Spatial
# Calculates and applies camera viewbob, based on input from the player's character controller.
# TODO: change UserSettings references...
#   - to exported values?
#   - to ProjectSettings?
#   - to public properties

const CAMERA_BOB_SPEED := 15
const CAMERA_BOB_DISTANCE := 0.15
const CAMERA_INTERPOLATE_SPEED := 10
const CAMERA_ROLL_TURN_DISTANCE := 0.4
const CAMERA_ROLL_STRAFE_DISTANCE := 0.05
const CAMERA_WALK_ROLL_DISTANCE := 0.015

var _camera_bob_weight := 0.0


# Calculates and smoothly interpolates to new transform.
# Call this from the player character controller's `_physics_process()`.
func update_transform(delta: float, is_walking: bool, turn_amount: float, strafe_direction: float):
	self._camera_bob_weight = self._camera_bob_weight + delta if is_walking else 0.0

	transform = transform.interpolate_with(
		_get_target_transform(_camera_bob_weight, turn_amount, strafe_direction), delta * CAMERA_INTERPOLATE_SPEED
	)


# TODO: Refactor
static func _get_target_transform(bob_weight: float, turn_amount: float, strafe_direction: float) -> Transform:
	var target_camera_offset := Transform.IDENTITY
	target_camera_offset.origin.y = (sin(-bob_weight * CAMERA_BOB_SPEED) * CAMERA_BOB_DISTANCE)  # * UserSettings.get_value("camera", "y_bob_amount")
	target_camera_offset = target_camera_offset.rotated(Vector3.BACK, turn_amount * CAMERA_ROLL_TURN_DISTANCE)  #* UserSettings.get_value("camera", "turn_roll_amount")
	target_camera_offset = target_camera_offset.rotated(Vector3.FORWARD, strafe_direction * CAMERA_ROLL_STRAFE_DISTANCE)  #* UserSettings.get_value("camera", "strafe_roll_amount")

	return target_camera_offset
