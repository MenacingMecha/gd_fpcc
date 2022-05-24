extends KinematicBody
# Handles responses to player input by applying movement and triggering interactions with the game world.

# const CameraViewbob := preload("res://player/camera_viewbob.gd")
# const InputDirection := preload("res://player/input_direction.gd")
const CameraViewbob := preload("camera_viewbob.gd")
const InputDirection := preload("input_direction.gd")

const GRAVITY := -24.8  # TODO: change to a private onready that grabs from project settings
const MAX_SPEED := 10
const MOVE_ACCEL := 4.5
const MOVE_DEACCEL := 16.0  # TODO: Rename or give description here
const MAX_SLOPE_ANGLE := 40
const MAX_CAMERA_X_DEGREE := 70.0

var mouse_look_sensitivity := 0.1
var _input_move_vector := Vector2.ZERO  # TODO: This is re-initialized every tick - tracking state is unneeded here
var _velocity := Vector3.ZERO
var _turn_amount := 0.0  # TODO: This is re-initialized every tick - delete if possible
var _camera_turned_this_update := false  # TODO: can we eliminate this state?

onready var _camera := $RotationHelper/Camera as Camera
onready var _camera_viewbob := $RotationHelper/Camera as CameraViewbob
onready var _rotation_helper := $RotationHelper as Spatial


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_turn_camera(-(event as InputEventMouseMotion).relative)

	elif event.is_action_type():
		self._input_move_vector = InputDirection.get_movement_direction()


func _physics_process(delta: float):
	var dir := Vector3.ZERO  # TODO: rename - what is `dir` referring to? Direction?

	# Walking
	var cam_xform = self._camera.get_global_transform()

	# Basis vectors are already normalized.
	dir += -cam_xform.basis.z * self._input_move_vector.y
	dir += cam_xform.basis.x * self._input_move_vector.x

	var camera_direction := InputDirection.get_input_direction(InputDirection.DirectionTypes.LOOK)
	var camera_rotation := camera_direction  # * float(UserSettings.get_value("input", "analogue_look_sensitivity"))  # TODO: move to project settings

	if camera_rotation != Vector2.ZERO:
		_turn_camera(camera_rotation)

	self._velocity = _process_velocity(delta, self._velocity, dir)

	var is_walking := self._input_move_vector.length_squared() > 0

	_camera_viewbob.update_transform(delta, is_walking, _turn_amount, _input_move_vector.x)

	# TODO: what's happening here?
	if !_camera_turned_this_update:
		_turn_amount = 0
	_camera_turned_this_update = false


# Calculates and applies velocity to physics body based on input, returning the new velocity.
# TODO: "calculates AND applies" - the calculating can be made fully static, move the applying elsewhere
func _process_velocity(delta: float, velocity: Vector3, input_direction: Vector3) -> Vector3:
	input_direction.y = 0
	velocity.y += delta * GRAVITY
	var h_vel := Vector3(velocity.x, 0, velocity.z)

	input_direction = input_direction.normalized()
	var accel := MOVE_ACCEL if input_direction.dot(h_vel) > 0.0 else MOVE_DEACCEL

	var target = input_direction * MAX_SPEED
	h_vel = h_vel.linear_interpolate(target, accel * delta)
	velocity.x = h_vel.x
	velocity.z = h_vel.z
	return move_and_slide(velocity, Vector3.UP, 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))


# Turns the player's Y rotation by `amount.y`, and the camera's X rotation by `amount.x`.
# X rotation is clamped by `MAX_CAMERA_X_DEGREE`.
func _turn_camera(amount: Vector2):
	self._rotation_helper.rotation_degrees.x = clamp(  
		self._rotation_helper.rotation_degrees.x + (amount.y * self.mouse_look_sensitivity), -MAX_CAMERA_X_DEGREE, MAX_CAMERA_X_DEGREE
	)
	var y_turn := deg2rad(amount.x * self.mouse_look_sensitivity)
	self.rotate_y(y_turn)
	self._turn_amount = -y_turn
	self._camera_turned_this_update = true
