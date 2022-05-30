extends GutTest

const PlayerController := preload("res://player/player_controller.gd")

const PLAYER_CONTROLLER_SCENE := preload("res://player/player.tscn")
const TEST_MAP := preload("res://test-map.tscn")
const DEFAULT_MOUSE_POSITION := Vector2.ZERO
const FLOAT_ERROR_MARGIN := 0.001


func test_can_fall_with_gravity():
	var player_controller: PlayerController = add_child_autofree(PLAYER_CONTROLLER_SCENE.instance())
	simulate(player_controller, 1, 2)
	assert_lt(player_controller.translation.y, 0.0)


func test_can_turn_horizontally_with_mouse(params = use_parameters([Vector2.LEFT, Vector2.RIGHT])):
	var player_controller: PlayerController = add_child_autofree(PLAYER_CONTROLLER_SCENE.instance())
	player_controller.can_capture_mouse_motion = true
	var input_sender = InputSender.new(player_controller)
	input_sender.mouse_set_position(DEFAULT_MOUSE_POSITION)
	input_sender.mouse_relative_motion(params)
	var expected_y_rotation: float = -params.x * player_controller.mouse_look_sensitivity
	assert_almost_eq(player_controller.rotation_degrees.y, expected_y_rotation, FLOAT_ERROR_MARGIN)


func test_can_turn_vertically_with_mouse(params = use_parameters([Vector2.UP, Vector2.DOWN])):
	var player_controller: PlayerController = add_child_autofree(PLAYER_CONTROLLER_SCENE.instance())
	player_controller.can_capture_mouse_motion = true
	var input_sender = InputSender.new(player_controller)
	input_sender.mouse_set_position(DEFAULT_MOUSE_POSITION)
	input_sender.mouse_relative_motion(params)
	var expected_x_rotation: float = -params.y * player_controller.mouse_look_sensitivity
	assert_almost_eq(player_controller.get_rotation_helper_x_rotation(), expected_x_rotation, FLOAT_ERROR_MARGIN)


func test_cant_look_vertically_past_max(params = use_parameters([Vector2.UP, Vector2.DOWN])):
	var player_controller: PlayerController = add_child_autofree(PLAYER_CONTROLLER_SCENE.instance())
	player_controller.can_capture_mouse_motion = true
	var input_sender = InputSender.new(player_controller)
	input_sender.mouse_set_position(DEFAULT_MOUSE_POSITION)
	input_sender.mouse_relative_motion(params * player_controller.MAX_CAMERA_X_DEGREE * 2)
	assert_between(
		player_controller.get_rotation_helper_x_rotation(),
		-player_controller.MAX_CAMERA_X_DEGREE,
		player_controller.MAX_CAMERA_X_DEGREE
	)


func test_can_turn_horizontally_with_joypad(params = use_parameters([Vector2.LEFT, Vector2.RIGHT])):
	var player_controller: PlayerController = add_child_autofree(PLAYER_CONTROLLER_SCENE.instance())
	var expected_y_rotation: float = -params.x * player_controller.joy_look_sensitivity
	player_controller.get_input_direction().get_axis_look_joy().fake_direction = params
	simulate(player_controller, 1, 1)
	assert_almost_eq(player_controller.rotation_degrees.y, expected_y_rotation, FLOAT_ERROR_MARGIN)


func test_can_turn_vertically_with_joypad(params = use_parameters([Vector2.UP, Vector2.DOWN])):
	var player_controller: PlayerController = add_child_autofree(PLAYER_CONTROLLER_SCENE.instance())
	player_controller.get_input_direction().get_axis_look_joy().fake_direction = params
	simulate(player_controller, 1, 1)
	var expected_x_rotation: float = -params.y * player_controller.joy_look_sensitivity
	assert_almost_eq(player_controller.get_rotation_helper_x_rotation(), expected_x_rotation, FLOAT_ERROR_MARGIN)


func test_can_walk_forward(params = use_parameters([Vector2.UP, Vector2.DOWN])):
	var player_controller: PlayerController = add_child_autofree(PLAYER_CONTROLLER_SCENE.instance())
	player_controller.get_input_direction().get_axis_move_joy().fake_direction = params
	simulate(player_controller, 1, 1)
	var min_z: float = params.y * 2
	var max_z: float = params.y * 10
	assert_between(player_controller.translation.z, min(min_z, max_z), max(min_z, max_z))


func test_can_walk_sideways(params = use_parameters([Vector2.LEFT, Vector2.RIGHT])):
	var player_controller: PlayerController = add_child_autofree(PLAYER_CONTROLLER_SCENE.instance())
	player_controller.get_input_direction().get_axis_move_joy().fake_direction = params
	simulate(player_controller, 1, 1)
	var min_x: float = params.x * 2
	var max_x: float = params.x * 10
	assert_between(player_controller.translation.x, min(min_x, max_x), max(min_x, max_x))


func test_walk_direction_is_based_on_forward_direction(params = use_parameters([Vector2.UP, Vector2.DOWN])):
	var player_controller: PlayerController = add_child_autofree(PLAYER_CONTROLLER_SCENE.instance())
	player_controller.rotation.y = 90.0
	player_controller.get_input_direction().get_axis_move_joy().fake_direction = params
	simulate(player_controller, 1, 1)
	var min_x: float = params.y * 2
	var max_x: float = params.y * 10
	assert_between(player_controller.translation.x, min(min_x, max_x), max(min_x, max_x))


# WITH a PlayerController with no gravity
# WHEN we walk for a second while looking straight ahead
# AND reset the velocty and position
# AND walk for a second while looking up/down
# THEN both walks should have the same duration
func test_looking_up_or_down_doesnt_decrease_speed(params = use_parameters([Vector2.UP, Vector2.DOWN])):
	var player_controller: PlayerController = PLAYER_CONTROLLER_SCENE.instance()
	player_controller.gravity = 0.0
	add_child_autofree(player_controller)

	var move_axis := player_controller.get_input_direction().get_axis_move_joy()
	move_axis.fake_direction = Vector2.UP
	simulate(player_controller, 1, 1)
	var distance_when_looking_straight := player_controller.translation.length_squared()

	player_controller.translation = Vector3.ZERO
	player_controller.velocity = Vector3.ZERO

	var input_sender = InputSender.new(player_controller)
	input_sender.mouse_set_position(DEFAULT_MOUSE_POSITION)
	input_sender.mouse_relative_motion(params * player_controller.MAX_CAMERA_X_DEGREE)
	simulate(player_controller, 1, 1)
	var distance_when_looking_not_straight := player_controller.translation.length_squared()

	assert_almost_eq(distance_when_looking_straight, distance_when_looking_not_straight, FLOAT_ERROR_MARGIN)

# func test_can_walk_up_slopes():

# func test_doesnt_slide_down_slopes():
