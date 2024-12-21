#if !defined(using_map_DATUM)
	#include "defuse_areas.dm"
	#include "../oldfare/warfare_shuttles.dm"
	#include "../oldfare/warfare_unit_testing.dm"
	#include "../oldfare/jobs/captain_verbs.dm"
	#include "jobs/defuse_jobs.dm"
	#include "jobs/soldiers.dm"
	#include "jobs/fortress.dm"
	#include "jobs/blue/blue_fortress.dm"
	#include "jobs/blue/blue_soldiers.dm"
	#include "jobs/red/red_fortress.dm"
	#include "jobs/red/red_soldiers.dm"
	#include "defuse_items.dm"
	#include "../shared/items/clothing.dm"
	#include "../shared/items/cards_ids.dm"

	#include "de_test.dmm"
	//#include "../astrafare/warfare-2.dmm"

	#include "../../code/modules/lobby_music/generic_songs.dm"

	#define using_map_DATUM /datum/map/defuse

#elif !defined(MAP_OVERRIDE)

	#warn A map has already been included, ignoring Example

#endif
