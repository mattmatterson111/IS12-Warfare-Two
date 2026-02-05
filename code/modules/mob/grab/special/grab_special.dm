/datum/grab/special
	icon = 'icons/mob/screen1.dmi'
	stop_move = 1
	can_absorb = 1
	shield_assailant = 1 //NYEHEHEHEHE
	point_blank_mult = 1
	force_danger = 1

/obj/item/grab/special/init()
	..()

	if(affecting.w_uniform)
		affecting.w_uniform.add_fingerprint(assailant)

	assailant.put_in_active_hand(src)
	//assailant.do_attack_animation(affecting)
	playsound(affecting.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
	var/obj/O = get_targeted_organ()
	var/grab_string = O.name
	if(assailant.zone_sel.selecting == BP_THROAT)
		grab_string = "throat"
	visible_message("<span class='warning'>[assailant] grabs [affecting]'s [grab_string]!</span>")
	affecting.grabbed_by += src

/obj/item/grab/special/strangle
	type_name = GRAB_STRANGLE
	start_grab_name = GRAB_STRANGLE

/datum/grab/special/strangle
	type_name = GRAB_STRANGLE
	icon_state = "strangle"
	state_name = GRAB_STRANGLE

/datum/grab/special/strangle/attack_self_act(var/obj/item/grab/G)
	do_strangle(G)

/datum/grab/special/strangle/process_effect(var/obj/item/grab/G)
	var/mob/living/carbon/human/affecting = G.affecting
	
	if(!G.wielded) //strangle with both hands
		activate_effect = FALSE
		G.assailant.visible_message("<span class='warning'>[G.assailant] stops strangling [G.affecting].</span>")
		return
	
	affecting.drop_l_hand()
	affecting.drop_r_hand()

	if(affecting.lying)
		affecting.Weaken(4)

	affecting.adjustOxyLoss(1)

	affecting.apply_effect(STUTTER, 5) //It will hamper your voice, being choked and all.
	affecting.Weaken(5)	//Should keep you down unless you get help.
	affecting.losebreath = max(affecting.losebreath + 2, 3)

/datum/grab/special/strangle/proc/do_strangle(var/obj/item/grab/G)
	var/mob/living/carbon/human/assailant = G.assailant
	var/mob/living/carbon/human/affecting = G.affecting
	if(!assailant || !affecting || !assailant.Adjacent(affecting)) //no force choking please
		G.force_drop()
		return
	if(!G.wielded)
		G.assailant.visible_message("<span class='warning'>Strangle with both hands!")
		return

	activate_effect = !activate_effect
	G.assailant.visible_message("<span class='combat_success'>[G.assailant] [activate_effect ? "starts" : "stops"] strangling [G.affecting].</span>")


/obj/item/grab/special/wrench
	type_name = GRAB_WRENCH
	start_grab_name = GRAB_WRENCH


/datum/grab/special/wrench
	type_name = GRAB_WRENCH
	icon_state = "wrench"
	state_name = GRAB_WRENCH

/datum/grab/special/wrench/attack_self_act(var/obj/item/grab/G)
	do_wrench(G)
	if(G.assailant) //if the grab gets broken before this finishes
		G.assailant.setClickCooldown(DEFAULT_SLOW_COOLDOWN)

/datum/grab/special/wrench/proc/do_wrench(var/obj/item/grab/G)
	var/obj/item/organ/external/O = G.get_targeted_organ()
	var/mob/living/carbon/human/assailant = G.assailant
	var/mob/living/carbon/human/affecting = G.affecting
	var/necksnap = FALSE
	
	if(assailant.doing_something)
		to_chat(assailant, "<span class='warning'>Already doing something!</span>")
		return
		
	assailant.doing_something = TRUE // can't spam use the bone breakage anymore.
	
	if(!O)
		to_chat(assailant, "<span class='warning'>[affecting] is missing that body part!</span>")
		assailant.doing_something = FALSE
		return
	if(!G.wielded)
		to_chat(assailant, "<span class='warning'>We must wield them in both hands to break their limb.</span>")
		assailant.doing_something = FALSE
		return
	if(!assailant || !affecting || !assailant.Adjacent(affecting))  //you don't have the force.
		G.force_drop()
		assailant.doing_something = FALSE
		return
		
	if(G.target_zone == BP_HEAD)
		var/bad_arc = reverse_direction(affecting.dir)
		if(!assailant.lying && !affecting.lying && !check_shield_arc(affecting, bad_arc, null, assailant) || !assailant.lying && affecting.lying)
			necksnap = TRUE //you have to be right behind them and they have to be looking away from you, or they have to be on the ground and you standing

	var/meleeskill = assailant.SKILL_LEVEL(melee)
	
	if(necksnap == TRUE)
		assailant.visible_message("<span class='danger'>[assailant] tries to break [affecting]'s neck!</span>")
	else
		assailant.visible_message("<span class='danger'>[assailant] tries to break [affecting]'s [O.name]!</span>")
	
	if(!do_after(assailant, (30 - meleeskill), affecting))
		assailant.doing_something = FALSE
		return

	if(necksnap == TRUE) // The limb is broken and we're grabbing it in both hands.
		assailant.doing_something = FALSE
		var/break_chance = O.damage/5 + assailant.STAT_LEVEL(str) - affecting.STAT_LEVEL(end) //did you know neck snapping irl is heavily impractical?
		if(prob(break_chance))
			assailant.visible_message("<span class='combat_success'>[assailant] snaps [affecting]'s neck!</span>")
			for(var/i in 1 to 20)
				affecting.apply_damage(5, BRUTE, BP_HEAD, 0) //we dont want their head to explode
			if(!O.is_broken()) //break if not already broken
				O.fracture()
			else
				if(O.break_sound)
					playsound(affecting, O.break_sound, 100, 0) //*crunch*
			affecting.death() //kill em.
			return
		else
			assailant.visible_message("<span class='danger'>[assailant] failed to snap [affecting]'s neck!</span>")
			playsound(affecting, O.break_sound, 25, 0) //small crunch
			affecting.apply_damage(assailant.STAT_LEVEL(str), BRUTE, BP_HEAD, 0)
			return

	else if(!O.is_broken()) // The limb isn't broken and we're grabbing it in both hands.
		var/break_chance = O.damage/2 + assailant.STAT_LEVEL(str) * 2 - affecting.STAT_LEVEL(end) // Changed.
		assailant.doing_something = FALSE
		if(break_chance <= 0)
			break_chance = 10
		if(prob(break_chance))
			to_chat(assailant, "<span class='combat_success'>Broke [affecting]'s [O.name]!</span>")
			O.fracture()
			return
		else
			O.jostle_bone(assailant.STAT_LEVEL(str), TRUE)
			playsound(affecting, O.break_sound, 50, 0)
			to_chat(assailant, "<span class='warning'>Failed to break [affecting]'s [O.name]!</span>")
			return
	else
		O.jostle_bone(assailant.STAT_LEVEL(str) * 2, TRUE)
		to_chat(assailant, "<span class='combat_success'>[assailant] breaks [affecting]'s [O.name] even more!</span>")
		playsound(affecting, O.break_sound, 100, 0)
		assailant.doing_something = FALSE
		return

/obj/item/grab/special/takedown
	type_name = GRAB_TAKEDOWN
	start_grab_name = GRAB_TAKEDOWN

/datum/grab/special/takedown
	type_name = GRAB_TAKEDOWN
	state_name = GRAB_TAKEDOWN
	icon_state = "takedown"

/datum/grab/special/takedown/attack_self_act(var/obj/item/grab/G)
	do_takedown(G)
	if(G.assailant) //if the grab gets broken before this finishes
		G.assailant.setClickCooldown(DEFAULT_SLOW_COOLDOWN)

/datum/grab/special/takedown/process_effect(var/obj/item/grab/G)
	// Keeps those who are on the ground down
	if(G.affecting.lying)
		G.affecting.Weaken(4)
		
	if(!G.wielded) //Pin with both hands
		activate_effect = FALSE
		G.assailant.visible_message("<span class='warning'>[G.assailant] stops keeping [G.affecting] on the ground!</span>")
		return


/datum/grab/special/takedown/proc/do_takedown(var/obj/item/grab/G)
	activate_effect = !activate_effect
	var/mob/living/carbon/human/affecting = G.affecting
	var/mob/living/carbon/human/assailant = G.assailant
	
	if(assailant.doing_something)
		to_chat(assailant, "<span class='warning'>Already doing something!</span>")
		return
		
	assailant.doing_something = TRUE 
	
	if(!assailant || !affecting || !assailant.Adjacent(affecting))  //you aren't darth vader
		G.force_drop()
		assailant.doing_something = FALSE
		return

	var/meleeskill = assailant.SKILL_LEVEL(melee)
	
	affecting.visible_message("<span class='notice'>[assailant] is trying to pin [affecting] to the ground!</span>")
	
	if(!do_after(assailant, (30 - meleeskill), affecting))
		assailant.doing_something = FALSE
		return

	if(!G.attacking && !affecting.lying)
	
		assailant.doing_something = FALSE

		G.attacking = 1

		if(!assailant.statscheck(assailant.STAT_LEVEL(str) / 2 + 3) >= SUCCESS && do_mob(assailant, affecting, 30))

			G.attacking = 0
			G.action_used()
			affecting.Weaken(2)
			affecting.visible_message("<span class='combat_success'>[assailant] pins [affecting] to the ground!</span>")
			return 1
		else
			affecting.visible_message("<span class='warning'>[assailant] fails to pin [affecting] to the ground.</span>")
			G.attacking = 0
			return 0
	else //they're lying down
		G.assailant.visible_message("<span class='combat_success'>[G.assailant] [activate_effect ? "starts" : "stops"] keeping [G.affecting] on the ground!</span>")
		assailant.doing_something = FALSE
		return 0

/datum/grab/special/self
	icon_state = "self"
	
/datum/grab/special/resolve_openhand_attack(var/obj/item/grab/G)
	if(G.assailant.a_intent != I_HELP)
		if(G.assailant.zone_sel.selecting == BP_HEAD && G.target_zone == BP_HEAD || G.assailant.zone_sel.selecting == BP_HEAD && G.target_zone == BP_THROAT) // grab head or throat and target head for headbutting
			if(!usr.lying) // bit hard to headbutt while lying down
				if(headbutt(G))
					usr.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
					return 1
			else
				to_chat(usr, "<span class='warning'>I can't headbutt while lying down!</span>")
				return 1
		else if(G.assailant.zone_sel.selecting == BP_EYES && G.target_zone == BP_HEAD || G.assailant.zone_sel.selecting == EYES && G.target_zone == BP_THROAT) //grab head or throat and target eyes for eye gouging
			if(attack_eye(G))
				usr.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
				return 1
	return 0
	
/datum/grab/special/proc/attack_eye(var/obj/item/grab/G)
	var/mob/living/carbon/human/attacker = G.assailant
	var/mob/living/carbon/human/target = G.affecting

	var/datum/unarmed_attack/attack = attacker.get_unarmed_attack(target, BP_EYES)

	if(!attack)
		return
	for(var/obj/item/protection in list(target.head, target.wear_mask, target.glasses))
		if(protection && (protection.body_parts_covered & EYES))
			to_chat(attacker, "<span class='danger'>You're going to need to remove the eye covering first.</span>")
			return
	if(!target.has_eyes())
		to_chat(attacker, "<span class='danger'>You cannot locate any eyes on [target]!</span>")
		return

	admin_attack_log(attacker, target, "Grab attacked the victim's eyes.", "Had their eyes grab attacked.", "attacked the eyes, using a grab action, of")

	attack.handle_eye_attack(attacker, target)
	return 1
	
/datum/grab/special/proc/headbutt(var/obj/item/grab/G)
	var/mob/living/carbon/human/attacker = G.assailant
	var/mob/living/carbon/human/target = G.affecting

	if(target.lying)
		return
		
	attacker.adjustStaminaLoss(10)

	var/damage = attacker.STAT_LEVEL(str)
	var/defense = target.STAT_LEVEL(end)
	var/obj/item/clothing/hat = attacker.head
	var/damage_flags = 0
	if(istype(hat))
		damage += hat.force * 3
		damage_flags = hat.damage_flags()

	if(damage_flags & DAM_SHARP)
		attacker.visible_message("<span class='combat_success'>[attacker] gores [target][istype(hat)? " with \the [hat]" : ""]!</span>")
	else
		attacker.visible_message("<span class='combat_success'>[attacker] thrusts \his head into [target]'s skull!</span>")

	var/armor = target.run_armor_check(BP_HEAD, "melee")
	target.apply_damage(damage, BRUTE, BP_HEAD, armor, damage_flags)
	attacker.apply_damage((damage/2), BRUTE, BP_HEAD, attacker.run_armor_check(BP_HEAD, "melee"))

	if(armor <= 50 && target.headcheck(BP_HEAD) && prob(damage - defense)) //so normal soldiers have a small chance to get knocked out
		target.apply_effect(20, PARALYZE)
		target.visible_message("<span class='combat_success'>[target] [target.species.get_knockout_message(target)]</span>")

	playsound(attacker.loc, "swing_hit", 25, 1, -1)

	admin_attack_log(attacker, target, "Headbutted their victim.", "Was headbutted.", "headbutted")
	return 1
	
/datum/grab/special/resolve_item_attack(var/obj/item/grab/G, var/mob/living/carbon/human/user, var/obj/item/I)
	if(G.target_zone == BP_THROAT || G.target_zone == BP_HEAD) //grab throat or head for throat slitting
		if(G.assailant.zone_sel.selecting == BP_THROAT)
			return attack_throat(G, I, user)
	else if(G.target_zone == G.assailant.zone_sel.selecting) //grab and target limb to sever tendon
		return attack_tendons(G, I, user, G.assailant.zone_sel.selecting)
	else
		return
			
/datum/grab/special/proc/attack_tendons(var/obj/item/grab/G, var/obj/item/W, var/mob/living/carbon/human/user, var/target_zone)
	var/mob/living/carbon/human/affecting = G.affecting

	if(user.a_intent != I_HURT)
		return 0 // Not trying to hurt them.

	if(!W.edge || !W.force || W.damtype != BRUTE)
		return 0 //unsuitable weapon

	var/obj/item/organ/external/O = G.get_targeted_organ()
	if(!O || O.is_stump() || !O.has_tendon || (O.status & ORGAN_TENDON_CUT))
		return FALSE
		
	if(user.doing_something)
		to_chat(user, "<span class='warning'>Already doing something!</span>")
		return
		
	user.doing_something = TRUE

	user.visible_message("<span class='danger'>\The [user] begins to cut \the [affecting]'s [O.tendon_name] with \the [W]!</span>")
	
	var/meleeskill = user.SKILL_LEVEL(melee)
	
	user.next_move = world.time + 20 - meleeskill
	
	if(!do_after(user, (20 - meleeskill), progress=0))
		user.doing_something = FALSE
		return 0
	if(!(G && G.affecting == affecting)) //check that we still have a grab
		user.doing_something = FALSE
		return 0
	if(O.sever_tendon())
		user.visible_message("<span class='combat_success'>\The [user] cut \the [affecting]'s [O.tendon_name] with \the [W]!</span>")
		if(W.hitsound) playsound(affecting.loc, W.hitsound, 50, 1, -1)
		G.last_action = world.time
		admin_attack_log(user, affecting, "hamstrung their victim", "was hamstrung", "hamstrung")
		user.doing_something = FALSE
		return 1 //we severed it!
	
	user.doing_something = FALSE
	return 0 //we didn't sever the tendon

/datum/grab/special/proc/attack_throat(var/obj/item/grab/G, var/obj/item/W, var/mob/living/carbon/human/user)
	var/mob/living/carbon/human/affecting = G.affecting
	var/obj/item/organ/external/O = G.get_targeted_organ()
	var/decapitation = FALSE
	
	if(user.a_intent != I_HURT)
		return 0 // Not trying to hurt them.

	if(!W.edge || !W.force || W.damtype != BRUTE)
		return 0 //unsuitable weapon
		
	if(user.doing_something)
		to_chat(user, "<span class='warning'>Already doing something!</span>")
		return
		
	user.doing_something = TRUE
		
	if(O.status & ORGAN_ARTERY_CUT) //Balancing so you can't instantly cut off someones head for free, you work for that shit.
		decapitation = TRUE
		user.visible_message("<span class='danger'>\The [user] begins to cut [affecting]'s head off with \the [W]!</span>")
	else
		user.visible_message("<span class='danger'>\The [user] begins to slit [affecting]'s throat with \the [W]!</span>")

	var/meleeskill = user.SKILL_LEVEL(melee)
	
	user.next_move = world.time + 20 - meleeskill //also should prevent user from triggering this repeatedly

	if(decapitation == TRUE)
		if(!do_after(user, (40 - meleeskill), progress = 0)) //it should take longer to cut off someones head no?
			user.doing_something = FALSE
			return 0
	else if(!do_after(user, (20 - meleeskill), progress = 0))
		user.doing_something = FALSE
		return 0
	
	if(!(G && G.affecting == affecting)) //check that we still have a grab
		user.doing_something = FALSE
		return 0

	var/damage_mod = 1
	//presumably, if they are wearing a helmet that stops pressure effects, then it probably covers the throat as well
	var/obj/item/clothing/head/helmet = affecting.get_equipped_item(slot_head)
	if(istype(helmet) && (helmet.body_parts_covered & HEAD) && (helmet.item_flags & ITEM_FLAG_STOPPRESSUREDAMAGE))
		//we don't do an armor_check here because this is not an impact effect like a weapon swung with momentum, that either penetrates or glances off.
		damage_mod = 1.0 - (helmet.armor["melee"]/100)

	var/total_damage = 0
	var/damage_flags = W.damage_flags()
	for(var/i in 1 to 3)
		var/damage = max(W.force*1.5, 20)*damage_mod
		affecting.apply_damage(damage, W.damtype, BP_HEAD, 0, damage_flags, used_weapon=W)
		total_damage += damage

	if(total_damage)
		if(decapitation == TRUE && prob(O.damage/5 + user.STAT_LEVEL(str))) //around 30-40% average at max damage?
			var/obj/item/organ/external/head = affecting.get_organ(BP_HEAD)
			user.visible_message("<span class='combat_success'>\The [user] cut [affecting]'s head off with \the [W]!</span>")
			head.droplimb(0, DROPLIMB_EDGE)
		else
			if(decapitation == TRUE) //we failed to cut off the head
				user.visible_message("<span class='danger'>\The [user] failed to cut [affecting]'s head off with \the [W]!</span>")
			else
				user.visible_message("<span class='combat_success'>\The [user] slit [affecting]'s throat open with \the [W]!</span>")
		
			if(O.sever_artery()) //FUKKEN KILLEM YEAAAAHHHH
				user.visible_message("<span class='combat_success'>\The [affecting]'s [O.artery_name] was severed!</span>")	

		if(W.hitsound)
			playsound(affecting.loc, W.hitsound, 50, 1, -1)

	G.last_action = world.time

	admin_attack_log(user, G.assailant, "Knifed their victim", "Was knifed", "knifed")
	user.doing_something = FALSE
	return 1