extends RefCounted
class_name DevelopmentFlags

# 0.2.0 planning flags.
# This file is intentionally not autoloaded yet so the 0.1.0 MVP flow stays untouched.

const TARGET_VERSION: String = "0.2.0"
const ROADMAP_BRANCH: String = "feature/0.2.0-foundation"

const ENABLE_VISUAL_CLASS_PLACEHOLDERS: bool = false
const ENABLE_BASE_3D_NAVIGATION: bool = false
const ENABLE_MOBILE_JOYSTICK_REWORK: bool = false
const ENABLE_ORBIT_CAMERA: bool = false
const ENABLE_DUNGEON_PORTAL_INTERACTION: bool = false
const ENABLE_EXPLORATION_TO_BATTLE_TRANSITION: bool = false
const ENABLE_RETURN_TO_BASE_FLOW: bool = false

static func is_any_0_2_0_feature_enabled() -> bool:
	return (
		ENABLE_VISUAL_CLASS_PLACEHOLDERS
		or ENABLE_BASE_3D_NAVIGATION
		or ENABLE_MOBILE_JOYSTICK_REWORK
		or ENABLE_ORBIT_CAMERA
		or ENABLE_DUNGEON_PORTAL_INTERACTION
		or ENABLE_EXPLORATION_TO_BATTLE_TRANSITION
		or ENABLE_RETURN_TO_BASE_FLOW
	)
