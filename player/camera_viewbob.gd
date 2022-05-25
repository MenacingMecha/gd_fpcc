extends Spatial
# Calculates and applies camera viewbob, based on input from the player's character controller.
# This is all visual and feel-based, so not really a good candidate for unit testing

const CAMERA_BOB_SPEED := 15
const CAMERA_BOB_DISTANCE := 0.15
const CAMERA_INTERPOLATE_SPEED := 10
const CAMERA_ROLL_TURN_DISTANCE := 0.4
const CAMERA_ROLL_STRAFE_DISTANCE := 0.05
const CAMERA_WALK_ROLL_DISTANCE := 0.015

var y_bob_amount := 1.0
var turn_roll_amount := 1.0
var strafe_roll_amount := 1.0
var _camera_bob_weight := 0.0


# Calculates and smoothly interpolates to a new transform.
# Call this from the player character controller's `_physics_process()`.
func update_transform(delta: float, is_walking: bool, turn_amount: float, strafe_direction: float):
	self._camera_bob_weight = self._camera_bob_weight + delta if is_walking else 0.0

	var target_transform := _get_target_transform(
		_camera_bob_weight,
		turn_amount,
		strafe_direction,
		self.y_bob_amount,
		self.turn_roll_amount,
		self.strafe_roll_amount
	)

	self.transform = self.transform.interpolate_with(target_transform, delta * CAMERA_INTERPOLATE_SPEED)


# Calculates target transform based on input parameters
static func _get_target_transform(
	bob_weight: float,
	turn_amount: float,
	strafe_direction: float,
	p_y_bob_amount: float,
	p_turn_roll_amount: float,
	p_strafe_roll_amount: float
) -> Transform:
	var target_camera_offset := Transform.IDENTITY
	var y_bob := Transform.IDENTITY.translated(
		Vector3.DOWN * sin(-bob_weight * CAMERA_BOB_SPEED) * CAMERA_BOB_DISTANCE * p_y_bob_amount
	)
	var turn_roll := Transform.IDENTITY.rotated(
		Vector3.BACK, turn_amount * CAMERA_ROLL_TURN_DISTANCE * p_turn_roll_amount
	)
	var strafe_roll := Transform.IDENTITY.rotated(
		Vector3.FORWARD, strafe_direction * CAMERA_ROLL_STRAFE_DISTANCE * p_strafe_roll_amount
	)

	return y_bob * turn_roll * strafe_roll
