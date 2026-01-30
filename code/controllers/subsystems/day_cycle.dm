SUBSYSTEM_DEF(day_cycle)
	name = "Day Cycle"
	wait = 1 SECONDS
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME
	
/datum/controller/subsystem/day_cycle/fire()
	GLOB.day_cycle_controller.update_cycle()

