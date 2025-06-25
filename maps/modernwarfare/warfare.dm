#if !defined(using_map_DATUM)
	#include "warfare_areas.dm"
	#include "../oldfare/warfare_shuttles.dm"
	#include "../oldfare/warfare_unit_testing.dm"
	#include "../oldfare/jobs/captain_verbs.dm"
	#include "../coldfare/jobs/warfare_jobs.dm"
	#include "../coldfare/jobs/soldiers.dm"
	#include "../coldfare/jobs/fortress.dm"
	#include "../coldfare/jobs/blue/blue_fortress.dm"
	#include "jobs/blue/blue_soldiers.dm"
	#include "../coldfare/jobs/red/red_fortress.dm"
	#include "jobs/red/red_soldiers.dm"
	#include "warfare_items.dm"
	#include "../shared/items/clothing.dm"
	#include "../shared/items/cards_ids.dm"

	#include "coldfare.dmm"
	//#include "../astrafare/warfare-2.dmm"

	#include "../../code/modules/lobby_music/generic_songs.dm"

	#define using_map_DATUM /datum/map/warfare

#elif !defined(MAP_OVERRIDE)

	#warn A map has already been included, ignoring Example

#endif
