/area
	var/is_mortar_area = FALSE

// check /datum/controller/subsystem/warfare for warfare vars and procs

/datum/game_mode/warfare
	name = "Warfare"
	round_description = "All out warfare on the battlefront!"
	extended_round_description = "Invade the enemies trenches and then destroy them! War is heck! Expect to die a lot!"
	config_tag = "warfare"
	required_players = 0
	auto_recall_shuttle = TRUE //If the shuttle is even somehow called.

/datum/game_mode/warfare/declare_completion()
	SSwarfare.declare_completion()

/datum/game_mode/warfare/post_setup()
	..()
	SSwarfare.begin_countDown()


/datum/game_mode/warfare/check_finished()
	if(SSwarfare.check_completion())
		return TRUE
	..()


/mob/living/carbon/human/proc/handle_warfare_death()
	if(!iswarfare())
		return
	if(is_npc)
		return
	if(src in SSwarfare.blue.team)//If in the team.
		SSwarfare.blue.left--//Take out a life.
		SSwarfare.blue.team -= src//Remove them from the team.
	if(src in SSwarfare.red.team)//Same here.
		SSwarfare.red.left--
		SSwarfare.red.team -= src
	
	if(warfare_faction == RED_TEAM) // Also fires for ghosts if they somehow die but mostly for humans
		IO_output("game_events:OnRedDeath", null, null)
	else if(warfare_faction == BLUE_TEAM)
		IO_output("game_events:OnBlueDeath", null, null)

	if(client)
		client.warfare_deaths++

	// as far as i know there are no immediate jobtype vars in mind or human, so here we go
	/*
	if(SSjobs?.GetJobByTitle(job)?.type == /datum/job/soldier/red_soldier/captain)
		for(var/X in SSwarfare.red.team)
			var/mob/living/carbon/human/H = X
			H.add_event("captain death", /datum/happiness_event/captain_death)
	if(SSjobs?.GetJobByTitle(job)?.type == /datum/job/soldier/blue_soldier/captain)
		for(var/X in SSwarfare.blue.team)
			var/mob/living/carbon/human/H = X
			H.add_event("captain death", /datum/happiness_event/captain_death)
	*/
	if(SSjobs?.GetJobByTitle(job)?.open_when_dead)//When the person dies who has this job, free this role again.
		SSjobs.allow_one_more(job)

	if(SSjobs?.GetJobByTitle(job)?.close_when_dead)//This is only for special units. Close the role when they die so that cargo has to buy another guy. This means you can only buy one special unit at a time.
		SSjobs?.GetJobByTitle(job)?.total_positions = 0

/mob/living/carbon/human/proc/handle_warfare_life()
	if(!iswarfare())
		return

	if(tracking)
		tracking.update()

/proc/iswarfare()
    return (istype(ticker.mode, /datum/game_mode/warfare) || master_mode=="warfare")

//Simple job check. Not meant to be used for any serious backend stuff. The "role" var is meant to be a string. - Stuff
/mob/proc/HasRoleSimpleCheck(var/role)
	if(mind.assigned_role == role)
		return TRUE
	else
		return FALSE