SUBSYSTEM_DEF(daylight)
	name = "Daylight"
	wait = 1 SECONDS
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME
	
/datum/controller/subsystem/daylight/fire()
	GLOB.daylight_controller.update_cycle()
