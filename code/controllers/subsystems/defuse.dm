#define KOTH_VICTORY_POINTS 500

/datum/team
	var/list/team = list()  // members of the team
	var/list/team_clients = list()
	var/list/cooldown = list()  // captain verbs that are being cooled down and cant be used
	var/points = 0 //KOTH stuff, trench capping game mode doesn't use this.
	var/nuked = FALSE //When set to true this side instantly loses. PONR uses it.
	var/left = 70 //Number of reinforcements both sides have.
	var/datum/squad/squadA
	var/datum/squad/squadB
	var/datum/squad/squadC
	var/datum/squad/squadD

/datum/team/New()
	..()
	squadA = new /datum/squad/alpha
	squadB = new /datum/squad/bravo
	squadC = new /datum/squad/charlie
	squadD = new /datum/squad/delta


/datum/squad
	var/name = "Default Squad"
	var/mob/squad_leader
	var/list/members = list()

/datum/squad/alpha
	name = "Alpha"

/datum/squad/bravo
	name = "Bravo"

/datum/squad/charlie
	name = "Charlie"

/datum/squad/delta
	name = "Delta"

/datum/team/proc/startCooldown(var/thingToCoolDown, var/time = 1 MINUTE)
	cooldown |= thingToCoolDown
	spawn(time)
		cooldown -= thingToCoolDown

/datum/team/proc/checkCooldown(var/thingToCheck)
	return thingToCheck in cooldown

SUBSYSTEM_DEF(warfare)
	name = "Defuse"
	flags = SS_NO_FIRE
	wait = 1
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY
	var/datum/team/blue
	var/datum/team/red
	var/battle_wait = 2 MINUTES
	var/battle_time = 0
	var/complete = ""
	var/obj/bomb = null
	var/allow_observe = FALSE
	var/bombwentoff = FALSE

/datum/controller/subsystem/warfare/Initialize()
	blue = new /datum/team
	red = new /datum/team
	SSwarfare = src
	..()

/datum/controller/subsystem/warfare/proc/end_warfare(var/loser)
	if(loser == RED_TEAM)
		red.nuked = TRUE
	if(loser == BLUE_TEAM)
		blue.nuked = TRUE

/datum/controller/subsystem/warfare/proc/begin_countDown()
	//spawn(config.warfare_start_time MINUTES)	// :disgust:
	spawn(20 SECONDS)	// :disgust:
		start_battle()

/datum/controller/subsystem/warfare/proc/start_battle()
	if(battle_time)  // so if it starts early, it doesnt @everyone again
		return
	battle_time = TRUE
	ticker.restart_timeout = 100
	for(var/client/C in GLOB.clients)
		if(C.warfare_faction == BLUE_TEAM)
			to_chat(C,"<big>DOWN WITH REDISTAN!</big>")

		else if(C.warfare_faction == RED_TEAM)
			to_chat(C,"<big>DEFEND REDISTAN!</big>")
	config.enter_allowed = !(config.enter_allowed)
	if (!(config.enter_allowed))
		to_world("<B>New players may no longer enter the game until the next round.</B>")
	config.abandon_allowed = !(config.abandon_allowed)
	if(!(config.abandon_allowed))
		to_world("<B>You can't respawn until the next round, either..</B>")
	allow_observe = TRUE
	world.update_status()

	var/redamount = 0
	var/blueamount = 0
	for(var/mob/M in GLOB.player_list)
		if(!M.client)
			return
		if(M.warfare_faction == RED_TEAM)
			redamount += 1
		else if(M.warfare_faction == BLUE_TEAM)
			blueamount += 1

	red.left = redamount
	blue.left = blueamount
	to_world("[redamount] Vs. [blueamount]")
	for(var/obj/hammereditor/playerclip/defuse/barrier in world) // ONLY CALLED ONCE BUT THIS IS FUCKED!!
		qdel(barrier)

	//sound_to(world, 'sound/effects/ready_to_die.ogg')//Sound notifying them.

	/*
	for(var/turf/simulated/floor/dirty/fake/F in world)//Make all the fake dirt into real dirt.
		F.ChangeTurf(/turf/simulated/floor/dirty)
	for(var/turf/simulated/floor/trench/fake/T in world)//Make all the fake trenches into real ones.
		T.ChangeTurf(/turf/simulated/floor/trench)
	*/

	//sound_to(world, sound('sound/ambience/distant_warfare.ogg', repeat = 1))

/datum/controller/subsystem/warfare/proc/check_completion()
	if(red.nuked)
		return TRUE
	else if(blue.nuked)
		return TRUE
	else if(red.left <= 0)
		if(!bombwentoff)
			return TRUE
	else if(blue.left <= 0)
		if(!bomb) // having the bomb planted means that wiping out the terrorists doesn't end the round till it blows
			return TRUE
	else if(red.points >= KOTH_VICTORY_POINTS)
		return TRUE
	else if(blue.points >= KOTH_VICTORY_POINTS)
		return TRUE

/datum/controller/subsystem/warfare/proc/declare_completion()

	//Point of no return
	if(red.nuked)
		feedback_set_details("round_end_result","win-blue team point of no return")
		complete = "win-blue team point of no return"
		to_world("<FONT size = 3><B>[BLUE_TEAM] GLORIOUS VICTORY!</B></FONT>")
		to_world("<B>\The [BLUE_TEAM] managed to successfully plant, and defend the bomb! Redistan is destabilized! We stand strong!</B>")
		//assign_victory(TRUE)

	else if(blue.nuked)
		feedback_set_details("round_end_result","win-red team point of no return")
		complete = "win-red team point of no return"
		to_world("<FONT size = 3><B>[RED_TEAM] GLORIOUS VICTORY!</B></FONT>")
		to_world("<B>\The [BLUE_TEAM] managed to successfully plant, but failed to defend the bomb! Redistan stands strong!</B>")
		//assign_victory(FALSE, TRUE)

	else if(red.left <= 0)
		feedback_set_details("round_end_result","win-blue team no reinforcements")
		complete = "win-blue team no reinforcements"
		to_world("<FONT size = 3><B>[BLUE_TEAM] GLORIOUS VICTORY!</B></FONT>")
		to_world("<B>\The [BLUE_TEAM] managed to end all of the [RED_TEAM]! The country is destabilized!</B>")
		//assign_victory(TRUE)

	else if(blue.left <= 0)
		feedback_set_details("round_end_result","win-red team no reinforcements")
		complete = "win-red team no reinforcements"
		to_world("<FONT size = 3><B>[RED_TEAM] GLORIOUS VICTORY!</B></FONT>")
		to_world("<B>\The [RED_TEAM] managed to end all of the [BLUE_TEAM]! Glory to Redistan! We stand strong!</B>")
		//assign_victory(FALSE, TRUE)

/*
	//KOTH shit
	else if(red.points >= KOTH_VICTORY_POINTS)
		feedback_set_details("round_end_result","win-red team koth")
		complete = "win-red team koth"
		to_world("<FONT size = 3><B>[RED_TEAM] Major Victory!</B></FONT>")
		to_world("<B>\The [RED_TEAM] managed to capture the command point!</B>")
		assign_victory(FALSE, TRUE)

	else if(blue.points >= KOTH_VICTORY_POINTS)
		feedback_set_details("round_end_result","win-blue team koth")
		complete = "win-blue team koth"
		to_world("<FONT size = 3><B>[BLUE_TEAM] Major Victory!</B></FONT>")
		to_world("<B>\The [BLUE_TEAM] managed to capture the command point!</B>")
		assign_victory(TRUE)
*/
	sound_to(world,'sound/ambience/round_over.ogg')
/*
	for(var/mob/M in GLOB.player_list)
		if(!M.client)
			return
		if(M.client.warfare_deaths <= 0)
			M.unlock_achievement(new/datum/achievement/warfare_survivor())
*/
/*
/datum/controller/subsystem/warfare/proc/assign_victory(var/blue = FALSE, var/red = FALSE) //This literally exists to give an achivement. Go fuck yourself.
	for(var/client/C in GLOB.clients)
		if(blue && C.warfare_faction == BLUE_TEAM)
			C.unlock_achievement(new/datum/achievement/warfare_victory())

		else if(red && C.warfare_faction == RED_TEAM)
			C.unlock_achievement(new/datum/achievement/warfare_victory())
*/