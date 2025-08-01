// This does NOT process the type of plant that's in a tray. It only does the spreading vines like kudzu.
PROCESSING_SUBSYSTEM_DEF(vines)
	name = "Vines"
	priority = SS_PRIORITY_VINES
	runlevels = RUNLEVEL_GAME|RUNLEVEL_POSTGAME
	flags = SS_NO_INIT
	wait = 80
/* // fuck the runtime error up there, additionally, we will NEVER see vines.
	process_proc = PROC_BY_TYPE(/obj/effect/vine, Process)

	var/list/vine_list

/datum/controller/subsystem/processing/vines/PreInit()
	vine_list = processing // Simply setups a more recognizable var name than "processing"
*/