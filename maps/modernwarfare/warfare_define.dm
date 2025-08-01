
/datum/map/warfare
	name = "Coldfare"
	full_name = "Warfare"
	path = "warfare"
	station_name  = "Warfare"
	station_short = "Warfare"
	dock_name     = "Warfare"
	boss_name     = "Colonial Magistrate Authority"
	boss_short    = "CMA"
	company_name  = "Colonial Magistrate Space Residential Complex"
	company_short = "CMSRC"
	system_name = "hell"

	lobby_icon = 'maps/coldfare/fullscreen.dmi'
	lobby_screens = list("lobby")

	station_levels = list(1,2)
	contact_levels = list(1)
	player_levels = list(1,2)

	allowed_spawns = list("Arrivals Shuttle")
	base_turf_by_z = list("1" = /turf/simulated/floor/dirty, "2" = /turf/simulated/floor/dirty, "3" = /turf/simulated/floor/dirty)
	shuttle_docked_message = "The shuttle has docked."
	shuttle_leaving_dock = "The shuttle has departed from home dock."
	shuttle_called_message = "A scheduled transfer shuttle has been sent."
	shuttle_recall_message = "The shuttle has been recalled"
	emergency_shuttle_docked_message = "The emergency escape shuttle has docked."
	emergency_shuttle_leaving_dock = "The emergency escape shuttle has departed from %dock_name%."
	emergency_shuttle_called_message = "An emergency escape shuttle has been sent."
	emergency_shuttle_recall_message = "The emergency shuttle has been recalled"
	map_lore = "We've been sitting in these trenches for months. No word from central command. The shells keep dropping... there is no way out. Our only hope is to push forth into their trench instead. But we don't have that many men left, if we lose too many it's over for us. We must give it our all if we are to survive this winter."

/*
/datum/map/warfare/perform_map_generation()
	var/list/z_levels = list(1) //,2)
	var/list/templates = list(/datum/map_template/ruin/exoplanet/randbuilding1, /datum/map_template/ruin/exoplanet/randbuilding2, /datum/map_template/ruin/exoplanet/randbuilding3)

	do_small_ruin_generation(z_levels, templates, 5)
	//do_small_ruin_generation(list(1), list(/datum/map_template/ruin/exoplanet/smugglers_den), 1)
	//do_small_ruin_generation(list(1), list(/datum/map_template/ruin/exoplanet/crashed_ship), 1)
	//do_small_ruin_generation(list(1), list(/datum/map_template/ruin/exoplanet/bunker), 1)
	return 1
*/


//Overriding event containers to remove random events.
/datum/event_container/mundane
	available_events = list(
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Mortars1",/datum/event/mortar,100),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Mortars2",/datum/event/mortar,100),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Mortars3",/datum/event/mortar,100),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Mortars4",/datum/event/mortar,100)
		)

/datum/event_container/moderate
	available_events = list(
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Mortars1",/datum/event/mortar,100),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Mortars2",/datum/event/mortar,100),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Mortars3",/datum/event/mortar,100),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Mortars4",/datum/event/mortar,100)
	)

/datum/event_container/major
	available_events = list(
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Mortars1",/datum/event/mortar,100),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Mortars2",/datum/event/mortar,100),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Mortars3",/datum/event/mortar,100),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Mortars4",/datum/event/mortar,100)
	)