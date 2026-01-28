GLOBAL_LIST_EMPTY(special_cryospawns)  // Active CS units available for spawning, keyed by ID
GLOBAL_LIST_EMPTY(all_cryospawns)      // All CS units regardless of state, keyed by ID
GLOBAL_LIST_EMPTY(team_cryospawns)     // Active CS units by TEAM (RED_TEAM/BLUE_TEAM) for spawn resolution

/obj/structure/soldiercryo/special
	icon_state = "cryo_loaded-gray"
	empty_state = "cryo_used-gray"
	density = TRUE
	var/id                    // Identifier for enable/disable control (can be anything: RED_TEAM, "red_forward_1", etc)
	var/team                  // Which warfare faction this belongs to (RED_TEAM or BLUE_TEAM)
	var/enabled = TRUE        // Whether this CS unit is available for spawning

/obj/structure/soldiercryo/special/Initialize()
	. = ..()
	// Register in global all_cryospawns list (always tracked by ID)
	if(!length(GLOB.all_cryospawns[id]))
		GLOB.all_cryospawns[id] = list()
	GLOB.all_cryospawns[id] += src

	// Only add to active spawns if enabled
	if(enabled)
		// Add to ID-keyed list
		if(!length(GLOB.special_cryospawns[id]))
			GLOB.special_cryospawns[id] = list()
		GLOB.special_cryospawns[id] += src

		// Add to team-keyed list for spawn resolution
		if(team)
			if(!length(GLOB.team_cryospawns[team]))
				GLOB.team_cryospawns[team] = list()
			GLOB.team_cryospawns[team] += src

/obj/structure/soldiercryo/special/Destroy()
	// Remove from all lists
	if(length(GLOB.all_cryospawns[id]))
		GLOB.all_cryospawns[id] -= src
	if(length(GLOB.special_cryospawns[id]))
		GLOB.special_cryospawns[id] -= src
	if(team && length(GLOB.team_cryospawns[team]))
		GLOB.team_cryospawns[team] -= src
	. = ..()

/// Enable this CS unit for spawning
/obj/structure/soldiercryo/special/proc/enable_spawn()
	if(enabled)
		return
	enabled = TRUE

	// Add to ID-keyed list
	if(!length(GLOB.special_cryospawns[id]))
		GLOB.special_cryospawns[id] = list()
	GLOB.special_cryospawns[id] |= src

	// Add to team-keyed list
	if(team)
		if(!length(GLOB.team_cryospawns[team]))
			GLOB.team_cryospawns[team] = list()
		GLOB.team_cryospawns[team] |= src

/// Disable this CS unit from spawning
/obj/structure/soldiercryo/special/proc/disable_spawn()
	if(!enabled)
		return
	enabled = FALSE

	// Remove from ID-keyed list
	if(length(GLOB.special_cryospawns[id]))
		GLOB.special_cryospawns[id] -= src

	// Remove from team-keyed list
	if(team && length(GLOB.team_cryospawns[team]))
		GLOB.team_cryospawns[team] -= src

/obj/structure/soldiercryo/special/MouseDrop_T(mob/target, mob/user)
	return

/obj/structure/soldiercryo/special/attackby(obj/item/grab/normal/G, user)
	return

// Default red team CS units - ID matches team for backwards compatibility
/obj/structure/soldiercryo/special/red
	id = RED_TEAM
	team = RED_TEAM

// Default blue team CS units - ID matches team for backwards compatibility
/obj/structure/soldiercryo/special/blue
	id = BLUE_TEAM
	team = BLUE_TEAM

// Forward spawn examples - custom ID but still belongs to a team
// Mappers: create your own subtypes like this, or set id/team in StrongDMM
/obj/structure/soldiercryo/special/red/forward
	id = "red_forward"
	enabled = FALSE  // Starts disabled, enabled by spawn_shift landmark

/obj/structure/soldiercryo/special/blue/forward
	id = "blue_forward"
	enabled = FALSE  // Starts disabled, enabled by spawn_shift landmark
