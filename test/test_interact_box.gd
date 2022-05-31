extends GutTest

const InteractBox := preload("res://player/interact_box.gd")

const DEACTIVATED_COLLISION_LAYER_BIT := 0


func test_deactivating_disables_collision():
	var interact_box: InteractBox = add_child_autofree(InteractBox.new())
	interact_box.is_active = false
	assert_eq(interact_box.collision_layer, DEACTIVATED_COLLISION_LAYER_BIT)


func test_activating_enables_collision():
	var interact_box: InteractBox = add_child_autofree(InteractBox.new())
	interact_box.is_active = false
	var activated_collision_layer_bit := InteractBox.COLLISION_LAYER_BIT
	interact_box.is_active = true
	assert_eq(interact_box.collision_layer, activated_collision_layer_bit)


func test_is_active_is_respected_on_ready():
	var interact_box: InteractBox = InteractBox.new()
	interact_box.is_active = false
	add_child_autofree(interact_box)
	assert_eq(interact_box.collision_layer, DEACTIVATED_COLLISION_LAYER_BIT)


func test_one_shot_deactivates_after_use():
	var interact_box: InteractBox = add_child_autofree(InteractBox.new())
	interact_box.one_shot = true
	interact_box.on_interacted_with()
	assert_false(interact_box.is_active)
