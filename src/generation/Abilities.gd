extends Node

enum Ability {Project, Attack}

func has_ability(abils_mask: int, ability: Ability) -> bool:
	return (1 << ability) & abils_mask

func can_use(cur_abils: int, req_abils: int) -> bool:
	return req_abils & (~cur_abils)
