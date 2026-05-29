extends Resource
class_name CharacterAppearanceData

@export var class_id: String = "necromancer"
@export var gender: String = "masculine"
@export var skin_tone: int = 0
@export var hair_style: int = 0
@export var hair_color: int = 0
@export var eye_color: int = 0
@export var body_type: int = 1
@export var armor_skin: String = ""
@export var cape_skin: String = ""
@export var weapon_skin: String = ""
@export var aura_id: String = ""


func to_dictionary() -> Dictionary:
	return {
		"class_id": class_id,
		"gender": gender,
		"skin_tone": skin_tone,
		"hair_style": hair_style,
		"hair_color": hair_color,
		"eye_color": eye_color,
		"body_type": body_type,
		"armor_skin": armor_skin,
		"cape_skin": cape_skin,
		"weapon_skin": weapon_skin,
		"aura_id": aura_id
	}


static func from_dictionary(data: Dictionary, fallback_class_id: String = "necromancer") -> CharacterAppearanceData:
	var resource := CharacterAppearanceData.new()
	resource.class_id = str(data.get("class_id", fallback_class_id))
	resource.gender = str(data.get("gender", data.get("body_type", "masculine")))
	resource.skin_tone = _to_index(data.get("skin_tone", 0))
	resource.hair_style = _to_index(data.get("hair_style", 0))
	resource.hair_color = _to_index(data.get("hair_color", 0))
	resource.eye_color = _to_index(data.get("eye_color", 0))
	resource.body_type = _to_index(data.get("body_type", 1))
	resource.armor_skin = str(data.get("armor_skin", ""))
	resource.cape_skin = str(data.get("cape_skin", ""))
	resource.weapon_skin = str(data.get("weapon_skin", ""))
	resource.aura_id = str(data.get("aura_id", ""))
	return resource


static func _to_index(value: Variant) -> int:
	if value is int:
		return value
	if value is float:
		return int(value)
	return 0
