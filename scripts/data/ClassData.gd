extends RefCounted
class_name ClassData

static func get_all_classes() -> Dictionary:
	return {
		"necromancer": _build("necromancer", "Necromante", "Entre a vida e a morte, há servidão.", {"vida": 70, "mana": 130, "forca": 8, "defesa": 10, "inteligencia": 20, "agilidade": 10, "sorte": 12}, ["death_touch", "essence_drain"], "Invocação, drenagem e dano sombrio."),
		"assassin": _build("assassin", "Assassino", "Sombras sussurram seu nome.", {"vida": 80, "mana": 70, "forca": 14, "defesa": 9, "inteligencia": 8, "agilidade": 20, "sorte": 18}, ["backstab", "shadow_step"], "Ataques rápidos, críticos e veneno."),
		"warrior": _build("warrior", "Guerreiro", "Escudo e lâmina, uma só vontade.", {"vida": 120, "mana": 50, "forca": 18, "defesa": 16, "inteligencia": 6, "agilidade": 10, "sorte": 8}, ["steady_slash", "stone_stance"], "Linha de frente segura e consistente."),
		"archer": _build("archer", "Arqueiro", "O vento conta onde acertar.", {"vida": 85, "mana": 80, "forca": 13, "defesa": 8, "inteligencia": 7, "agilidade": 18, "sorte": 16}, ["piercing_arrow", "rapid_shot"], "Precisão, velocidade e dano à distância."),
		"mage": _build("mage", "Mago", "Realidade é frágil como papel.", {"vida": 65, "mana": 150, "forca": 6, "defesa": 6, "inteligencia": 22, "agilidade": 12, "sorte": 10}, ["spark", "ice_circle"], "Dano elemental e controle de turno."),
		"berserker": _build("berserker", "Berserker", "Vida plena e sangue quente.", {"vida": 125, "mana": 40, "forca": 22, "defesa": 7, "inteligencia": 5, "agilidade": 12, "sorte": 7}, ["frenzy_attack", "war_cry"], "Risco alto e explosão física."),
		"druid": _build("druid", "Druida", "Floresta, ouça-me.", {"vida": 90, "mana": 110, "forca": 9, "defesa": 12, "inteligencia": 17, "agilidade": 12, "sorte": 14}, ["creeping_thorns", "healing_touch"], "Cura, controle e magia natural."),
		"cleric": _build("cleric", "Clérigo", "Luz não fere, ela pesa.", {"vida": 95, "mana": 120, "forca": 10, "defesa": 13, "inteligencia": 16, "agilidade": 10, "sorte": 12}, ["blinding_light", "lesser_blessing"], "Suporte e purificação."),
		"paladin": _build("paladin", "Paladino", "Julgamento em forma de ação.", {"vida": 115, "mana": 85, "forca": 15, "defesa": 18, "inteligencia": 9, "agilidade": 9, "sorte": 9}, ["holy_strike", "protection_aura"], "Defesa sagrada e golpes pesados.")
	}


static func get_class_data(class_id: String) -> Dictionary:
	return get_all_classes().get(class_id, {})


static func _build(id: String, name: String, phrase: String, stats: Dictionary, skills: Array[String], role: String) -> Dictionary:
	return {
		"id": id,
		"display_name": name,
		"phrase": phrase,
		"stats": stats,
		"skills": skills,
		"role": role,
		"description": role,
		"icon": ""
	}
