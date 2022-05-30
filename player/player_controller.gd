extends KinematicBody
# Handles responses to player input by applying movement and triggering interactions with the game world.

const CameraViewbob := preload("camera_viewbob.gd")
const InputDirection := preload("input_direction.gd")
const MouseGrabber := preload("mouse_grabber.gd")

const MAX_SPEED := 10
const MOVE_ACCEL := 4.5
const MOVE_DEACCEL := 16.0  # TODO: Rename or give description here
const MAX_SLOPE_ANGLE := 40
const MAX_CAMERA_X_DEGREE := 70.0

var mouse_look_sensitivity := 0.1
var joy_look_sensitivity := 20.0
var velocity := Vector3.ZERO
var _turn_amount := 0.0  # TODO: This is re-initialized every tick - delete if possible
var _camera_turned_this_update := false  # TODO: can we eliminate this state?

onready var can_capture_mouse_motion := ($MouseGrabber as MouseGrabber).is_mouse_grabbed setget set_can_capture_mouse_motion
onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
onready var _camera := $RotationHelper/Camera as Camera
onready var _camera_viewbob := $RotationHelper/Camera as CameraViewbob
onready var _rotation_helper := $RotationHelper as Spatial
onready var _input_direction := $InputDirection as InputDirection


func _ready():
	($MouseGrabber as MouseGrabber).connect("mouse_grabbed", self, "set_can_capture_mouse_motion")


func _unhandled_input(event: InputEvent):
	if self.can_capture_mouse_motion and event is InputEventMouseMotion:
		_turn_camera(-(event as InputEventMouseMotion).relative * self.mouse_look_sensitivity)


func _physics_process(delta: float):
	var input_move_vector := self._input_direction.get_move_direction()
	var camera_rotation := -self._input_direction.get_look_direction() * joy_look_sensitivity

	if camera_rotation != Vector2.ZERO:
		_turn_camera(camera_rotation)

	self.velocity = _process_velocity(
		delta, self.velocity, _get_walk_direction(self._camera.get_global_transform(), input_move_vector)
	)

	var is_walking := input_move_vector.length_squared() > 0

	self._camera_viewbob.update_transform(delta, is_walking, self._turn_amount, input_move_vector.x)

	# TODO: what's happening here?
	if !_camera_turned_this_update:
		_turn_amount = 0
	_camera_turned_this_update = false


func set_can_capture_mouse_motion(new_state: bool):
	can_capture_mouse_motion = new_state


func get_rotation_helper_x_rotation() -> float:
	return self._rotation_helper.rotation_degrees.x


func get_input_direction() -> InputDirection:
	return self._input_direction


# Calculates and applies velocity to physics body based on input, returning the new velocity.
# TODO: "calculates AND applies" - the calculating can be made fully static, move the applying elsewhere
func _process_velocity(delta: float, velocity: Vector3, input_direction: Vector3) -> Vector3:
	input_direction.y = 0
	velocity.y -= delta * self.gravity
	var h_vel := Vector3(velocity.x, 0, velocity.z)

	input_direction = input_direction.normalized()
	var accel := MOVE_ACCEL if input_direction.dot(h_vel) > 0.0 else MOVE_DEACCEL

	var target = input_direction * MAX_SPEED
	h_vel = h_vel.linear_interpolate(target, accel * delta)
	velocity.x = h_vel.x
	velocity.z = h_vel.z
	return move_and_slide(velocity, Vector3.UP, 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))


# Basis vectors are already normalized.
static func _get_walk_direction(camera_transform: Transform, input_direction: Vector2) -> Vector3:
	return (-camera_transform.basis.z * -input_direction.y) + (camera_transform.basis.x * input_direction.x)


# Turns the player's Y rotation by `amount.y`, and the camera's X rotation by `amount.x`.
# X rotation is clamped by `MAX_CAMERA_X_DEGREE`.
func _turn_camera(amount: Vector2):
	self._rotation_helper.rotation_degrees.x = clamp(
		self._rotation_helper.rotation_degrees.x + amount.y, -MAX_CAMERA_X_DEGREE, MAX_CAMERA_X_DEGREE
	)
	var y_turn := deg2rad(amount.x)
	self.rotate_y(y_turn)
	self._turn_amount = -y_turn
	self._camera_turned_this_update = true
