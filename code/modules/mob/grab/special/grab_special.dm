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
	
	if(!G.wielded) //Strangle with both hands.
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
	if(!G.wielded)
		G.assailant.visible_message("<span class='warning'>Strangle with both hands!")
		return
	activate_effect = !activate_effect
	G.assailant.visible_message("<span class='warning'>[G.assailant] [activate_effect ? "starts" : "stops"] strangling [G.affecting].</span>")


/obj/item/grab/special/wrench
	type_name = GRAB_WRENCH
	start_grab_name = GRAB_WRENCH


/datum/grab/special/wrench
	type_name = GRAB_WRENCH
	icon_state = "wrench"
	state_name = GRAB_WRENCH

/datum/grab/special/wrench/attack_self_act(var/obj/item/grab/G)
	do_wrench(G)
	G.assailant.setClickCooldown(DEFAULT_SLOW_COOLDOWN)

/datum/grab/special/wrench/proc/do_wrench(var/obj/item/grab/G)
	var/obj/item/organ/external/O = G.get_targeted_organ()
	var/mob/living/carbon/human/assailant = G.assailant
	var/mob/living/carbon/human/affecting = G.affecting
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

	if(!do_after(assailant, 30, affecting))
		assailant.doing_something = FALSE
		return


	if(!O.is_broken()) // The limb is broken and we're grabbing it in both hands.
		assailant.visible_message("<span class='danger'>[assailant] tries to break [affecting]'s [O.name]!</span>")
		var/break_chance = (assailant.STAT_LEVEL(str)*10) - 105 // We have to have a strength over 12 to really have a chance of breaking a limb.
		assailant.doing_something = FALSE
		if(break_chance <= 0)
			break_chance = 10
		if(prob(break_chance))
			O.fracture()
		else
			to_chat(assailant, "<span class='danger'>Failed to break [affecting]'s [O.name]!</span>")
	else
		to_chat(assailant, "<span class='warning'>[affecting]'s [O.name] is already broken!</span>")
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

	if(!do_after(assailant, 30, affecting))
		assailant.doing_something = FALSE
		return

	if(!G.attacking && !affecting.lying)
	
		assailant.doing_something = FALSE

		affecting.visible_message("<span class='notice'>[assailant] is trying to pin [affecting] to the ground!</span>")
		G.attacking = 1

		if(!assailant.statscheck(assailant.STAT_LEVEL(str) / 2 + 3) >= SUCCESS && do_mob(assailant, affecting, 30))

			G.attacking = 0
			G.action_used()
			affecting.Weaken(2)
			affecting.visible_message("<span class='notice'>[assailant] pins [affecting] to the ground!</span>")
			return 1
		else
			affecting.visible_message("<span class='notice'>[assailant] fails to pin [affecting] to the ground.</span>")
			G.attacking = 0
			return 0
	else //they're lying down
		G.assailant.visible_message("<span class='warning'>[G.assailant] [activate_effect ? "starts" : "stops"] keeping [G.affecting] on the ground!</span>")
		assailant.doing_something = FALSE
		return 0

/datum/grab/special/self
	icon_state = "self"
	
/datum/grab/special/resolve_openhand_attack(var/obj/item/grab/G)
	if(G.assailant.a_intent != I_HELP)
		if(G.assailant.zone_sel.selecting == BP_HEAD && G.target_zone == BP_HEAD || G.assailant.zone_sel.selecting == BP_HEAD && G.target_zone == BP_THROAT) // grab head or throat and target head for headbutting
			if(headbutt(G))
				return 1
		else if(G.assailant.zone_sel.selecting == BP_EYES && G.target_zone == BP_HEAD || G.assailant.zone_sel.selecting == EYES && G.target_zone == BP_THROAT) //grab head or throat and target eyes for eye gouging
			if(attack_eye(G))
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

	var/damage = 20
	var/obj/item/clothing/hat = attacker.head
	var/damage_flags = 0
	if(istype(hat))
		damage += hat.force * 3
		damage_flags = hat.damage_flags()

	if(damage_flags & DAM_SHARP)
		attacker.visible_message("<span class='danger'>[attacker] gores [target][istype(hat)? " with \the [hat]" : ""]!</span>")
	else
		attacker.visible_message("<span class='danger'>[attacker] thrusts \his head into [target]'s skull!</span>")

	var/armor = target.run_armor_check(BP_HEAD, "melee")
	target.apply_damage(damage, BRUTE, BP_HEAD, armor, damage_flags)
	attacker.apply_damage(10, BRUTE, BP_HEAD, attacker.run_armor_check(BP_HEAD, "melee"))

	if(armor < 50 && target.headcheck(BP_HEAD) && prob(damage))
		target.apply_effect(20, PARALYZE)
		target.visible_message("<span class='danger'>[target] [target.species.get_knockout_message(target)]</span>")

	playsound(attacker.loc, "swing_hit", 25, 1, -1)

	admin_attack_log(attacker, target, "Headbutted their victim.", "Was headbutted.", "headbutted")
	return 1
	
/datum/grab/special/resolve_item_attack(var/obj/item/grab/G, var/mob/living/carbon/human/user, var/obj/item/I)
	if(G.target_zone == BP_THROAT || G.target_zone == BP_HEAD) //grab throat or head for throat slitting
		if(G.assailant.zone_sel.selecting == BP_THROAT)
			return attack_throat(G, I, user)
	else
		return attack_tendons(G, I, user, G.assailant.zone_sel.selecting) //this just defaults to normal knife behavior tf
			
/datum/grab/special/proc/attack_tendons(var/obj/item/grab/G, var/obj/item/W, var/mob/living/carbon/human/user, var/target_zone)
	var/mob/living/carbon/human/affecting = G.affecting

	if(user.a_intent != I_HURT)
		return 0 // Not trying to hurt them.

	if(!W.edge || !W.force || W.damtype != BRUTE)
		return 0 //unsuitable weapon

	var/obj/item/organ/external/O = G.get_targeted_organ()
	if(!O || O.is_stump() || !O.has_tendon || (O.status & ORGAN_TENDON_CUT))
		return FALSE

	user.visible_message("<span class='danger'>\The [user] begins to cut \the [affecting]'s [O.tendon_name] with \the [W]!</span>")
	user.next_move = world.time + 20

	if(!do_after(user, 20, progress=0))
		return 0
	if(!(G && G.affecting == affecting)) //check that we still have a grab
		return 0
	if(O.sever_tendon())
		user.visible_message("<span class='danger'>\The [user] cut \the [affecting]'s [O.tendon_name] with \the [W]!</span>")
		if(W.hitsound) playsound(affecting.loc, W.hitsound, 50, 1, -1)
		G.last_action = world.time
		admin_attack_log(user, affecting, "hamstrung their victim", "was hamstrung", "hamstrung")
		return 1 //we severed it!
	
	return 0 //we didn't sever the tendon

/datum/grab/special/proc/attack_throat(var/obj/item/grab/G, var/obj/item/W, var/mob/living/carbon/human/user)
	var/mob/living/carbon/human/affecting = G.affecting

	if(user.a_intent != I_HURT)
		return 0 // Not trying to hurt them.

	if(!W.edge || !W.force || W.damtype != BRUTE)
		return 0 //unsuitable weapon
	user.visible_message("<span class='danger'>\The [user] begins to slit [affecting]'s throat with \the [W]!</span>")

	user.next_move = world.time + 20 //also should prevent user from triggering this repeatedly
	if(!do_after(user, 20, progress = 0))
		return 0
	if(!(G && G.affecting == affecting)) //check that we still have a grab
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
		user.visible_message("<span class='danger'>\The [user] slit [affecting]'s throat open with \the [W]!</span>")

		if(W.hitsound)
			playsound(affecting.loc, W.hitsound, 50, 1, -1)

	G.last_action = world.time

	admin_attack_log(user, src, "Knifed their victim", "Was knifed", "knifed")
	return 1