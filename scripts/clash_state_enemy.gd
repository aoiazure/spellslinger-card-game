class_name EnemyClashState extends ClashState





static func create(_cur: int, _max: int, _statuses: Array[StatusModel] = []) -> EnemyClashState:
	var state:= EnemyClashState.new()
	state.cur_hp = _cur
	state.max_hp = _max
	state.statuses = _statuses
	
	return state








