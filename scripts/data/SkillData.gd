extends RefCounted
class_name SkillData

static func get_skill(skill_id: String) -> Dictionary:
	return get_all_skills().get(skill_id, {})


static func get_all_skills() -> Dictionary:
	return {
		"death_touch": {"name": "Toque Mortal", "mana_cost": 5, "description": "Dano mágico. Se derrotar, recupera mana."},
		"essence_drain": {"name": "Drenar Essência", "mana_cost": 10, "description": "Dano mágico e cura parcial."},
		"backstab": {"name": "Ataque Furtivo", "mana_cost": 0, "description": "Causa mais dano se agir antes do alvo."},
		"shadow_step": {"name": "Passo Sombrio", "mana_cost": 10, "description": "Esquiva garantida no próximo ataque inimigo."},
		"steady_slash": {"name": "Golpe Firme", "mana_cost": 0, "description": "Dano físico médio."},
		"stone_stance": {"name": "Postura Defensiva", "mana_cost": 8, "description": "Aumenta a defesa por dois turnos."},
		"piercing_arrow": {"name": "Flecha Perfurante", "mana_cost": 0, "description": "Ignora parte da defesa inimiga."},
		"rapid_shot": {"name": "Chuva de Flechas", "mana_cost": 12, "description": "Dois disparos rápidos no mesmo turno."},
		"spark": {"name": "Bola de Fogo", "mana_cost": 8, "description": "Dano elemental de fogo."},
		"ice_circle": {"name": "Círculo de Gelo", "mana_cost": 12, "description": "Dano mágico e lentidão."},
		"frenzy_attack": {"name": "Fúria", "mana_cost": 0, "description": "Quanto menos vida, mais dano."},
		"war_cry": {"name": "Grito de Batalha", "mana_cost": 10, "description": "Aumenta força, reduz defesa."},
		"creeping_thorns": {"name": "Espinhos", "mana_cost": 6, "description": "Dano natural e atraso do turno inimigo."},
		"healing_touch": {"name": "Toque Curativo", "mana_cost": 12, "description": "Restaura vida."},
		"blinding_light": {"name": "Luz Ofuscante", "mana_cost": 10, "description": "Cega o inimigo por dois turnos."},
		"lesser_blessing": {"name": "Bênção Leve", "mana_cost": 15, "description": "Cura e remove debuffs."},
		"holy_strike": {"name": "Golpe Sagrado", "mana_cost": 0, "description": "Dano físico com bônus sagrado."},
		"protection_aura": {"name": "Proteção do Escudo", "mana_cost": 10, "description": "Reduz o dano recebido."}
	}
