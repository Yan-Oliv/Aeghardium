extends RefCounted
class_name EquipmentVisualData

static func get_items() -> Dictionary:
	return {
		"short_sword": {
			"display_name": "Espada Curta",
			"slot": "main_hand",
			"weapon_type": "sword",
			"color": "B8C4D4"
		},
		"long_sword": {
			"display_name": "Espada Longa",
			"slot": "main_hand",
			"weapon_type": "sword",
			"color": "D8E0EA"
		},
		"simple_staff": {
			"display_name": "Cajado Simples",
			"slot": "main_hand",
			"weapon_type": "staff",
			"color": "6C4224",
			"gem_color": "56C8FF"
		},
		"wooden_bow": {
			"display_name": "Arco de Madeira",
			"slot": "main_hand",
			"weapon_type": "bow",
			"color": "7A4A24"
		},
		"twin_daggers": {
			"display_name": "Adagas",
			"slot": "main_hand",
			"weapon_type": "daggers",
			"color": "C6CEDA"
		},
		"hand_axe": {
			"display_name": "Machado",
			"slot": "main_hand",
			"weapon_type": "axe",
			"color": "B0B0B4"
		},
		"light_shield": {
			"display_name": "Escudo Leve",
			"slot": "offhand",
			"offhand_type": "shield",
			"color": "C6B46A"
		},
		"basic_robe": {
			"display_name": "Robe Basico",
			"slot": "chest",
			"body_type": "robe",
			"robe_color": "302476",
			"trim_color": "519AEC"
		},
		"iron_armor": {
			"display_name": "Armadura de Ferro",
			"slot": "chest",
			"body_type": "armor",
			"robe_color": "525862",
			"trim_color": "D2AA4C",
			"metal_color": "969EAA"
		},
		"shadow_cape": {
			"display_name": "Capa Sombria",
			"slot": "cape",
			"accessory": "cape",
			"color": "1C142A"
		}
	}


static func get_item(item_id: String) -> Dictionary:
	return get_items().get(item_id, {})


static func get_default_equipment_for_class(class_id: String) -> Dictionary:
	match class_id:
		"warrior":
			return {"main_hand": "long_sword", "chest": "iron_armor"}
		"paladin":
			return {"main_hand": "long_sword", "offhand": "light_shield", "chest": "iron_armor"}
		"assassin":
			return {"main_hand": "twin_daggers", "cape": "shadow_cape"}
		"archer":
			return {"main_hand": "wooden_bow", "cape": "shadow_cape"}
		"berserker":
			return {"main_hand": "hand_axe"}
		"mage", "necromancer", "druid", "cleric":
			return {"main_hand": "simple_staff", "chest": "basic_robe"}
	return {"main_hand": "short_sword"}


static func color_from_hex(hex_value: String, fallback: Color) -> Color:
	if hex_value.is_empty():
		return fallback
	return Color(hex_value)
