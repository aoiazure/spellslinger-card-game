## Static class that manages operations of commands on Fighters.
class_name FighterCmd extends Object





static func damage(target: ClashState, amount: int, owner: ClashState, _card: CardModel) -> void:
	await target.get_tree().create_timer(0.0).timeout
	
	var target_statuses: Array[StatusModel] = target.statuses.filter(
		func(s: StatusModel) -> bool:
			return s.affects_damage_taken
	)
	
	var owner_statuses: Array[StatusModel] = owner.statuses.filter(
		func(s: StatusModel) -> bool:
			return s.affects_damage_dealt
	)
	
	for status in target_statuses:
		if not status.affects_damage_taken:
			continue
		
		amount = status.affect(amount)
	
	for status in owner_statuses:
		if not status.affects_damage_dealt:
			continue
		
		amount = status.affect(amount)
	
	target.cur_hp = clampi(target.cur_hp - amount, 0, 999)

static func gain_hp(target: ClashState, amount: int, _owner: ClashState, _card: CardModel) -> void:
	await target.get_tree().create_timer(0.0).timeout
	target.cur_hp = clampi(target.cur_hp+amount, 0, target.max_hp)

static func draw_cards(target: ClashState, amount: int, _owner: ClashState, _card: CardModel) -> void:
	if (not target is PlayerClashState) or (not "hand" in target):
		push_error("%s cannot draw cards." % target)
		return
	
	await target.get_tree().create_timer(0.0).timeout
	(target as PlayerClashState).draw_card(amount)

static func discard_cards(
			target: ClashState, amount: int, _owner: ClashState, _card: CardModel
		) -> Array[CardModel]:
	
	if (not target is PlayerClashState) or (not "hand" in target):
		push_error("%s cannot discard cards." % target)
		return []
	
	var selected:= await FighterCmd.select_cards_in_zone(target, amount, ZoneViewer.Zones.HAND, _owner, _card)
	for card: CardModel in selected:
		(target as PlayerClashState).discard_card(card)
	
	return selected

static func select_cards_in_zone(
			target: ClashState, amount: int, zone: ZoneViewer.Zones, 
			_owner: ClashState, _card: CardModel
		) -> Array[CardModel]:
	
	if (not target is PlayerClashState) or (not "deck" in target):
		push_error("%s cannot select cards." % target)
		return []
	
	var selected: Array[CardModel] = []
	var zone_viewer:= target.get_tree().get_first_node_in_group("zone_viewer") as ZoneViewer
	var zone_data: Array[CardModel] = []
	match zone:
		ZoneViewer.Zones.HAND:
			zone_data = target.hand
		ZoneViewer.Zones.DECK:
			zone_data = target.deck
		ZoneViewer.Zones.GRAVE:
			zone_data = target.grave
	
	zone_viewer.set_up(zone_data)
	if zone_data.is_empty():
		selected = await zone_viewer.select_cards(0)
	else:
		selected = await zone_viewer.select_cards(amount)
	
	return selected



static func apply_status(target: ClashState, status: StatusModel, _owner: ClashState, _card: CardModel) -> void:
	await target.get_tree().create_timer(0.0).timeout
	target.add_status(status)

static func block(owner: ClashState, duration: int, amount: int, _card: CardModel) -> void:
	await owner.add_status(StatusModel.BlockShield.new(duration, amount))










