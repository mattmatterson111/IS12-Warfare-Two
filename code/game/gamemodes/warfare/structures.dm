/obj/structure/dirt_wall
	name = "dirt barricade"
	desc = "Be crouching behind this will stop you from getting shot by bullets!"
	icon = 'icons/obj/mounds_new.dmi'
	icon_state = "brustwehr_0"
	throwpass = TRUE//we can throw grenades despite its density
	anchored = TRUE
	density = FALSE
	//color = "#bfc0cf"// I Cba to resprite these rn so its just a recolor to make them blend in more. - Kas
	/// They have since then been resprited ^^
	//plane = PLATING_PLANE
	//layer = BASE_ABOVE_OBJ_LAYER
	//  Crates kept getting hidden under these. // Edit: cannot do that. It fucks up the turf smoothing overlays.
	plane = ABOVE_OBJ_PLANE
	layer = 26.1 // I want this to be under crates and items. || It also means that you can throw grenades back if they land on dirt cover.
	atom_flags = ATOM_FLAG_CLIMBABLE
	var/health = 100


/obj/structure/dirt_wall/New()
	..()
	update_nearby_icons()

/obj/structure/dirt_wall/proc/update_nearby_icons()
	update_icon()
	for(var/direction in GLOB.cardinal)
		for(var/obj/structure/dirt_wall/B in get_step(src,direction))
			B.update_icon()

/obj/structure/dirt_wall/update_icon()
	spawn(2)
		if(!src)
			return
		var/junction = 0 //will be used to determine from which side the barricade is connected to other barricades
		for(var/obj/structure/dirt_wall/B in orange(src,1))
			if(abs(x-B.x)-abs(y-B.y) ) 		//doesn't count barricades, placed diagonally to src
				junction |= get_dir(src,B)

		icon_state = "brustwehr_[junction]"

/obj/structure/dirt_wall/Crossed(var/atom/M)
	if(ismob(M))
		M.pixel_y = 12
	if(isobj(M))
		var/obj/O = M
		O.plane = ABOVE_OBJ_PLANE
		O.layer = ABOVE_OBJ_LAYER+1

/obj/structure/dirt_wall/Uncrossed(var/atom/M)
	if(ismob(M))
		M.pixel_y = 0

	if(isobj(M))
		var/obj/O = M
		O.plane = initial(O.plane)
		O.layer = initial(O.layer)

/obj/structure/dirt_wall/attackby(obj/O as obj, mob/user as mob)
	if(istype(O, /obj/item/shovel))
		if(!do_after(user, 50, src)) //we want to change mob pixel_y and fov after we finish do_after, not before it
			return
		for(var/mob/living/M in src.loc) // if someone standing on dirt wall - they will be shifted back to normal position
			Uncrossed(M)
		qdel(src)

/obj/structure/dirt_wall/RightClick(mob/user)
	if(!CanPhysicallyInteract(user))
		..()
		return
	if(do_after(user, 50))
		if(src)//If it's somehow deleted before hand.
			health = 100


/obj/structure/dirt_wall/bullet_act(var/obj/item/projectile/Proj)
	..()
	for(var/mob/living/carbon/human/H in loc)
		H.bullet_act(Proj)
	//visible_message("[Proj] hits the [src]!")
	playsound(src, "hitwall", 50, TRUE)
	health -= rand(1, 10)
	if(health <= 0)
		visible_message("<span class='danger'>The [src] crumbles!</span>")
		update_nearby_icons()
		qdel(src)

/obj/structure/dirt_wall/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			qdel(src)
			return
		if(3.0)
			if(prob(50))
				qdel(src)

/obj/structure/dirt_wall/Destroy()
	update_nearby_icons()
	. = ..()

/obj/structure/dirt_wall/attack_generic(var/mob/user, var/damage)
	return FALSE

/obj/structure/dirt_wall/fire_act(temperature)
	return

/obj/structure/dirt_wall/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(istype(mover, /obj/item/projectile))
		var/obj/item/projectile/proj = mover

		if(proj.firer && Adjacent(proj.firer))
			return TRUE

		if (get_dist(proj.starting, loc) <= 1)
			return TRUE

		return FALSE

	return TRUE


//Bullshit snowflake stuff for climbing over it.
/obj/structure/dirt_wall/do_climb(var/mob/living/user)
	if(!can_climb(user))
		return

	usr.visible_message("<span class='warning'>[user] starts climbing onto \the [src]!</span>")
	climbers |= user

	if(!do_after(user,(issmall(user) ? 20 : 34)))
		climbers -= user
		return

	if(!can_climb(user, post_climb_check=1))
		climbers -= user
		return

	if(!neighbor_turf_passable())
		to_chat(user, "<span class='danger'>You can't climb there, the way is blocked.</span>")
		climbers -= user
		return

	if(get_turf(user) == get_turf(src))
		usr.forceMove(get_step(src, src.dir))
	else
		usr.forceMove(get_turf(src))

	usr.visible_message("<span class='warning'>[user] climbed over \the [src]!</span>")
	climbers -= user

/obj/structure/dirt_wall/can_climb(var/mob/living/user, post_climb_check=0)
	if (!(atom_flags & ATOM_FLAG_CLIMBABLE) || !can_touch(user) || (!post_climb_check && (user in climbers)))
		return FALSE

	if (!user.Adjacent(src))
		to_chat(user, "<span class='danger'>You can't climb there, the way is blocked.</span>")
		return FALSE

	return TRUE


//NON DIRT BARRICADES

/obj/structure/warfare/barricade
	name = "barricade"
	desc = "it stops you from moving"
	icon = 'icons/obj/warfare.dmi'
	plane = ABOVE_OBJ_PLANE
	layer = BASE_ABOVE_OBJ_LAYER
	anchored = TRUE

/obj/structure/warfare/barricade/concrete_barrier
	name = "concrete barrier"
	desc = "Very effective at blocking bullets, but it gets in the way."
	icon_state = "concrete_block"


/obj/structure/warfare/barricade/New()
	..()
	if(dir == SOUTH)
		plane = ABOVE_HUMAN_PLANE


/obj/structure/warfare/barricade/CheckExit(atom/movable/O, turf/target)
	if(istype(O, /obj/item/projectile))//Blocks bullets unless you're ontop of it.
		var/obj/item/projectile/proj = O
		if(proj.firer.resting)//No resting and shooting over these.
			qdel(proj)
			return FALSE
		if(proj.firer && Adjacent(proj.firer))
			return TRUE
	if(get_dir(loc, target) & dir)
		return FALSE
	else
		return TRUE

/obj/structure/warfare/barricade/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /obj/item/projectile))//Blocks bullets unless you're ontop of it.
		var/obj/item/projectile/proj = mover

		if(proj.firer.resting)//No resting and shooting over these.
			return FALSE

		if(proj.firer && Adjacent(proj.firer))
			return TRUE

		if (get_dist(proj.starting, loc) <= 1)
			return TRUE

		return FALSE

	var/obj/structure/S = locate(/obj/structure) in get_turf(mover)
	if(S && !(S.atom_flags & ATOM_FLAG_CHECKS_BORDER) && isliving(mover)) //Climbable objects allow you to universally climb over others
		return TRUE

	if(get_dir(loc, target) & dir)
		return FALSE
	else
		return TRUE


//Bullshit snowflake stuff for climbing over it.
/obj/structure/warfare/barricade/do_climb(var/mob/living/user)
	if(!can_climb(user))
		return
	if(!SSwarfare.battle_time)
		return
	user.visible_message("<span class='warning'>[user] starts climbing onto \the [src]!</span>")
	climbers |= user

	if(!do_after(user,(issmall(user) ? 20 : 30)))
		climbers -= user
		return

	if(!can_climb(user, post_climb_check=1))
		climbers -= user
		return

	if(!neighbor_turf_passable())
		to_chat(user, "<span class='danger'>You can't climb there, the way is blocked.</span>")
		climbers -= user
		return

	if(get_turf(user) == get_turf(src))
		user.forceMove(get_step(src, src.dir))
	else
		user.forceMove(get_turf(src))

	user.visible_message("<span class='warning'>[user] climbed over \the [src]!</span>")
	climbers -= user

/obj/structure/warfare/barricade/can_climb(var/mob/living/user, post_climb_check=0)
	if (!(atom_flags & ATOM_FLAG_CLIMBABLE) || !can_touch(user) || (!post_climb_check && (user in climbers)))
		return FALSE

	if (!user.Adjacent(src))
		to_chat(user, "<span class='danger'>You can't climb there, the way is blocked.</span>")
		return FALSE

	return TRUE


//BARBWIRE

/obj/item/stack/barbwire
	name = "barbed wire"
	desc = "Use this to place down barbwire in front of your position."
	icon = 'icons/obj/warfare.dmi'
	icon_state = "barbwire_item"
	amount = 5
	max_amount = 5
	w_class = ITEM_SIZE_LARGE //fuck off you're not putting 30 stacks in your satchel

/obj/item/stack/barbwire/attack_self(var/mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/organ/external/affecting = H.get_organ(pick("l_arm", "r_arm", "l_hand", "r_hand")) //pick limb to get cut for failed skillcheck
	var/turf/T = get_step(user, user.dir)

	if(H.doing_something)
		return

	if(T)
		if(isopenspace(T))
			return
		if(turf_contains_dense_objects(T) || iswall(T)) //no 20 structures of barbed wire in one tile/in walls
			to_chat(H, "There's already something there!")
			return
		for(var/obj/structure/object in T)
			to_chat(H, "There's already something there!")
			return
		visible_message("[user] begins to place the [src]!")
		H.doing_something = TRUE
		if(do_after(user, 20)) //leave it in this statement, dont want people getting cut for getting bumped/moving during assembly
			H.doing_something = FALSE
			if(H.statscheck(skills = H.SKILL_LEVEL(engineering)) > CRIT_FAILURE) //Considering how useless barbwire seems to be, everyone can now spam it.
				to_chat(H, "You assemble the [src]!")
				amount--
				if(amount<=0)
					qdel(src)
				new /obj/structure/barbwire(T)
				return
			else
				playsound(loc, 'sound/effects/glass_step.ogg', 50, TRUE)
				if (affecting.status & ORGAN_ROBOT)
					return
				if (affecting.take_damage(3, FALSE)) //stop trying to put down barb wire without the skill dumbass
					H.UpdateDamageIcon()
				H.updatehealth()
				to_chat(H, "You fail to assemble the [src], cutting your [affecting.name]!")
		else
			H.doing_something = FALSE

/obj/structure/barbwire
	name = "barbed wire"
	desc = "Passing through this looks painful."
	icon = 'icons/obj/warfare.dmi'
	icon_state = "barbwire"
	anchored = TRUE
	plane = ABOVE_HUMAN_PLANE
	layer = BASE_MOB_LAYER

/obj/structure/barbwire/ex_act(severity)
	switch (severity)
		if (3)
			if (prob(50))
				qdel(src)
		else
			qdel(src)

/obj/structure/barbwire/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return TRUE

/obj/structure/barbwire/Crossed(AM as mob|obj)
	if (ismob(AM))
		var/mob/M = AM
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			if (prob (33))
				playsound(loc, "stab_sound", 50, TRUE)
				var/obj/item/organ/external/affecting = H.get_organ(pick("l_foot", "r_foot", "l_leg", "r_leg"))
				if (affecting.status & ORGAN_ROBOT)
					return
				if (affecting.take_damage(3, FALSE))
					H.UpdateDamageIcon()
				H.updatehealth()
				to_chat(H, "<span class = 'red'><b>Your [affecting.name] gets slightly cut by \the [src]!</b></span>")
			else if (prob (33))
				playsound(loc, "stab_sound", 50, TRUE)
				var/obj/item/organ/external/affecting = H.get_organ(pick("l_foot", "r_foot", "l_leg", "r_leg"))
				if (affecting.status & ORGAN_ROBOT)
					return
				if (affecting.take_damage(8, FALSE))
					H.UpdateDamageIcon()
				H.updatehealth()
				to_chat(H, "<span class = 'red'><b>Your [affecting.name] gets cut by \the [src]!</b></span>")
			else
				playsound(loc, "stab_sound", 50, TRUE)
				var/obj/item/organ/external/affecting = H.get_organ(pick("l_foot", "r_foot", "l_leg", "r_leg"))
				if (affecting.status & ORGAN_ROBOT)
					return
				if (affecting.take_damage(13, FALSE))
					H.UpdateDamageIcon()
				H.updatehealth()
				to_chat(H, "<span class = 'red'><b>Your [affecting.name] gets deeply cut by \the [src]!</b></span>")
	return ..()

/obj/structure/barbwire/Uncross(AM as mob)
	if(ismob(AM))
		var/mob/M = AM
		if (ishuman(M))
			if(prob(50))
				M.visible_message("<span class='danger'>[M] struggle to free themselves from the barbed wire!</span>")
				var/mob/living/carbon/human/H = M
				playsound(loc, "stab_sound", 50, TRUE)
				M.receive_damage()
				var/obj/item/organ/external/affecting = H.get_organ(pick("l_foot", "r_foot", "l_leg", "r_leg"))
				if (affecting.status & ORGAN_ROBOT)
					return
				if (affecting.take_damage(8, FALSE))
					H.UpdateDamageIcon()
				H.updatehealth()
				return FALSE
			else
				M.visible_message("<span class='danger'>[M] frees themself from the barbed wire!</span>")
				return TRUE
	return ..()

/obj/structure/barbwire/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/wirecutters))
		if (anchored)
			user.visible_message("<span class = 'notice'>\The [user] starts to cut through \the [src] with [W].</span>")
			if (!do_after(user,30))
				user.visible_message("<span class = 'notice'>\The [user] decides not to cut through the \the [src].</span>")
				return
			user.visible_message("<span class = 'notice'>\The [user] finishes cutting through \the [src], destroying it!</span>") //will think about adding chance to recover barbed wire piece with engineering skill
			playsound(loc, 'sound/items/Wirecutter.ogg', 50, TRUE)
			qdel(src)
			return

	else if (istype(W, /obj/item/material/sword))
		if (anchored)
			user.visible_message("<span class = 'notice'>\The [user] starts to cut through \the [src] with [W].</span>")
			if (!do_after(user,60))
				user.visible_message("<span class = 'notice'>\The [user] decides not to cut through \the [src].</span>")
				return
			else
				user.visible_message("<span class = 'notice'>\The [user] finishes cutting through \the [src], destroying it!</span>")
				playsound(loc, 'sound/items/Wirecutter.ogg', 50, TRUE)
				qdel(src)
				return

/obj/structure/telearray
	name = "Telescope Array"
	desc = "It's a part of this strange device. Was that a goal of our expedition?"
	icon = 'icons/obj/warfare.dmi'
	anchored = TRUE
	density = TRUE
	plane = ABOVE_OBJ_PLANE
	layer = BASE_MOB_LAYER

/obj/structure/telearray/lowleft
	icon_state = "telearray_ll"

/obj/structure/telearray/lowright
	icon_state = "telearray_lr"

/obj/structure/telearray/centreleft
	icon_state = "telearray_cl"

/obj/structure/telearray/centreright
	icon_state = "telearray_cr"

/obj/structure/telearray/upperleft
	icon_state = "telearray_ul"

/obj/structure/telearray/upperright
	icon_state = "telearray_ur"

/obj/structure/anti_tank
	name = "metal barricade"
	desc = "Usually found in no man\'s land IN YOUR FUCKING WAY. It's dense enough to block bullets, don't even try to fucking shoot over it."
	icon = 'icons/obj/warfare.dmi'
	icon_state = "anti-tank"
	anchored = TRUE
	density = TRUE
	plane = ABOVE_OBJ_PLANE
	layer = BASE_MOB_LAYER
	atom_flags = ATOM_FLAG_CLIMBABLE

/obj/structure/anti_tank/can_climb(var/mob/living/user, post_climb_check=0)
	if(!iswarfare())
		return TRUE
/* // howd this get here?

	if(istype(get_area(src), /area/warfare/battlefield/no_mans_land))//We're trying to go into no man's land?
		if(locate(/obj/item/device/boombox) in user)//Locate the boombox.
			to_chat(user, "I can't bring this with me onto the battlefield. Wouldn't want to lose it.")//No you fucking don't.
			return //Keep that boombox at base asshole.
		if(locate(/obj/item/storage) in user)//Gotta check storage as well.
			var/obj/item/storage/S = locate() in user
			if(locate(/obj/item/device/boombox) in S)
				to_chat(user, "I can't bring this with me onto the battlefield. Wouldn't want to lose it.")
				return

	if(!SSwarfare.battle_time)
		return FALSE
	return TRUE

*/
/obj/item/projectile/bullet/pellet/fragment/landmine
	damage = 100
	range_step = 2 //controls damage falloff with distance. projectiles lose a "pellet" each time they travel this distance. Can be a non-integer.
	base_spread = 0 //causes it to be treated as a shrapnel explosion instead of cone
	spread_step = 20
	range =  3 //dont kill everyone on the screen

/obj/item/landmine
	name = "landmine"
	desc = "Use it to place a landmine in front of you. Beee careful..."
	density = TRUE
	icon = 'icons/obj/warfare.dmi'
	icon_state = "mine_item"

/obj/item/landmine/CanPass(atom/movable/mover, turf/target, height, air_group)
	return TRUE

/obj/item/landmine/attack_self(var/mob/user)
	var/turf/T = get_step(user, user.dir)
	if(T)
		if(isopenspace(T))
			return
		if(turf_contains_dense_objects(T) || iswall(T)) //no 20 structures of barbed wire in one tile/in walls
			to_chat(H, "There's already something there!")
			return
		visible_message("[user] begins to place the mine!")
		if(do_after(user, 20))
			qdel(src)
			new /obj/structure/landmine(T)


/obj/structure/landmine
	name = "landmine"
	desc = "If you step on this you'll probably fucking die."
	icon = 'icons/obj/warfare.dmi'
	icon_state = "mine"
	anchored = TRUE
	density = FALSE
	var/armed = FALSE//Whether or not it will blow up.
	var/can_be_armed = TRUE//Whether or not it can be armed to blow up. Disarmed mines won't blow.
	var/mob/stepper = null // This prevents people that lay down or die on a landmine from making others think that they won't blow it if walk over it since it's already primed.
	var/glow_state = null // string to manually set the glow, otherwise its random blue/red

/obj/structure/landmine/blue
	glow_state = "mine_glow_alt"

/obj/structure/landmine/red
	glow_state = "mine_glow"

/obj/structure/landmine/New()
	..()
	if(prob(15))
		desc = "This mushroom is not for picking."
	update_icon()
	if(istype(src.loc, /turf/simulated/floor/exoplanet/water/shallow))
		qdel(src)

/obj/structure/landmine/proc/blow()
	GLOB.mines_tripped++
	fragmentate(get_turf(src), 20, 2, list(/obj/item/projectile/bullet/pellet/fragment/landmine))
	explosion(loc, 2, 2, 1, 1)
	qdel(src)

/obj/structure/landmine/update_icon()
	overlays.Cut()
	if(!glow_state)
		glow_state = "mine_glow"
		if(prob(50))
			glow_state = "[glow_state]_alt"
	var/image/I = image(icon=src.icon, icon_state=glow_state)
	I.plane = BLOOM_PLANE
	overlays += I
	if(!can_be_armed)
		overlays.Cut()
		icon_state = "mine_disarmed"


/obj/structure/landmine/attackby(obj/item/W as obj, mob/user as mob)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(istype(W, /obj/item/wirecutters))
		if(!can_be_armed)
			return
		H.visible_message("<span class='danger'>[H] begins to disarm the landmine...</span>")
		if(do_after(user,50))
			if(H.statscheck(skills = H.SKILL_LEVEL(engineering)) >= SUCCESS)
				armed = FALSE
				can_be_armed = FALSE
				to_chat(H, "You successfully disarm the [src]")
				GLOB.mines_disarmed++
				playsound(src, 'sound/items/Wirecutter.ogg', 100, FALSE)
				update_icon()
				stepper = null
				return
			blow()
	if(istype(W, /obj/item/shovel))
		if(!can_be_armed)
			H.visible_message("<span class='danger'>[H] begins to dig up the landmine...</span>")
			playsound(src, 'sound/effects/dig_shovel.ogg', 40, FALSE)
			if(do_after(user,50))
				to_chat(H, "You successfully dig up the [src]")
				qdel(src)
		return

/obj/structure/landmine/Crossed(var/mob/living/M as mob)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.isChild())//Kids don't set off landmines.
			return
		if(!armed && can_be_armed)
			if(M.throwing)
				sleep(3)
				if(!locate(M) in src.loc)
					return FALSE
				to_chat(M, "<span class='danger'>You hear a sickening click!</span>")
				playsound(src, 'sound/effects/mine_arm.ogg', 100, FALSE)
				armed = TRUE
				stepper = M
			else
				to_chat(M, "<span class='danger'>You hear a sickening click!</span>")
				playsound(src, 'sound/effects/mine_arm.ogg', 100, FALSE)
				armed = TRUE
				stepper = M

/obj/structure/landmine/Uncrossed(var/mob/living/M as mob)
	if(istype(M))
		if(armed)
			if(M == stepper) // HAH
				blow()



//Activate this to win!
/obj/structure/destruction_computer
	name = "Point Of No Return"
	desc = "DON'T LET THE ENEMY TOUCH THIS!"
	icon = 'icons/obj/warfare.dmi'
	icon_state = "destruct"
	anchored = TRUE
	density = TRUE
	var/faction = null
	var/activated = FALSE
	var/countdown_time
	var/doomsday_timer
	var/last_use
	var/used_by_person

/obj/structure/destruction_computer/New()
	..()
	name = "[faction] [name]"
	countdown_time = config.warfare_end_time MINUTES //Countdown time is in minutes because seconds is FUCKED.

/obj/structure/destruction_computer/attack_hand(mob/user)
	. = ..()
	if(REALTIMEOFDAY - last_use < 2 SECONDS)
		to_chat(user, "The device is scorching hot! I must wait a few seconds!") // Fuck the people that were spamming it
		return
	if(used_by_person)
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.warfare_faction == faction)
			if(!activated)
				return
			used_by_person = TRUE
			if(do_after(H,100))
				used_by_person = FALSE
				user.unlock_achievement(new/datum/achievement/deactivate())
				activated = FALSE
				deltimer(doomsday_timer)
				to_world(uppertext("<big>[H.warfare_faction] have disarmed the [src]!</big>"))
				playsound(src, 'sound/effects/mine_arm.ogg', 100, FALSE)
				sound_to(world, 'sound/effects/ponr_activate.ogg')
				stop_alarm("[name]_[faction]_PONR_Alarm")
				last_use = REALTIMEOFDAY
			else
				used_by_person = FALSE

		else
			if(activated)
				return
			used_by_person = TRUE
			if(do_after(H, 30))
				in_use = FALSE
				start_alarm("[name]_[faction]_PONR_Alarm", /datum/speaker_alarm/evil, faction)
				user.unlock_achievement(new/datum/achievement/point_of_no_return())
				playsound(src, 'sound/effects/mine_arm.ogg', 100, FALSE)
				sound_to(world, 'sound/effects/ponr_activate.ogg')
				to_world(uppertext("<big>[H.warfare_faction] have activated the [src]! They will achieve victory in [countdown_time/10] seconds!</big>"))
				activated = TRUE
				doomsday_timer = addtimer(CALLBACK(src,/obj/structure/destruction_computer/proc/kaboom), countdown_time, TIMER_STOPPABLE|TIMER_UNIQUE|TIMER_NO_HASH_WAIT|TIMER_OVERRIDE)
				last_use = REALTIMEOFDAY
			else
				used_by_person = FALSE
			used_by_person = FALSE

/obj/structure/destruction_computer/proc/kaboom()
	stop_alarm("[name]_[faction]_PONR_Alarm")
	SSwarfare.end_warfare(faction)//really simple I know.

/obj/structure/destruction_computer/red
	faction = RED_TEAM

/obj/structure/destruction_computer/blue
	faction = BLUE_TEAM


/obj/structure/banner
	name = "Banner"
	desc = "The glorious banner of uh... your side."
	icon = 'icons/obj/stationobjs.dmi'
	anchored = TRUE
	density = FALSE
	plane = ABOVE_HUMAN_PLANE
	layer = ABOVE_HUMAN_LAYER

/obj/structure/banner/red
	icon_state = "red"

/obj/structure/banner/red/small
	icon_state = "redsmall"

/obj/structure/banner/blue
	icon_state = "blue"

/obj/structure/banner/blue/small
	icon_state = "bluesmall"

/obj/structure/factionbanner
	name = "faction banner"
	desc = "Raise it, or die trying.<br>Portable now, too!<br><b>Left click to raise<br>Right click to lower</b>"
	icon = 'icons/obj/32x64.dmi'
	icon_state = "flag1"
	density = TRUE
	anchored = TRUE
	plane = ABOVE_HUMAN_PLANE
	layer = ABOVE_HUMAN_LAYER
	var/progress = 1
	var/mob/living/carbon/human/lastuser // forgive me lord
	var/currentfaction
	var/sound_id
	var/datum/sound_token/sound_token
	var/range = 3
	var/list/particleslist = list()

/obj/structure/factionbanner/CanPass(atom/movable/mover, turf/target, height, air_group)
	return TRUE

/obj/structure/factionbanner/update_icon() // not just for updating icons.. I'm sorry, fellow coders.
	. = ..()
	QDEL_NULL(sound_token)// just incase.
	currentfaction = null
	// just gonna place this here as a small sanity thing + it gets called anytime it gets changed so yeah
	if(progress>4 || 0>=progress) // it just hard resets it to 1 if multiple people were to try to raise it or lower it
		progress = 1
	if(progress == 4)
		icon_state = "flag3"
	else
		icon_state = "flag[progress]"
	overlays.Cut()
	if(progress == 4)
		if(lastuser.warfare_faction == RED_TEAM)
			for(var/turf/simulated/floor/T in view(range, src))
				if(!istype(T, /turf/simulated/open))
					set_light(4, 1, "#ee8080")
					T.color = "#ffe7e7"
					var/obj/particle_emitter/fire_sparks/fs = new(T)
					fs.particles.count = 4
					fs.particles.fade = 3
					fs.particles.lifespan = 3
					fs.particles.position = generator(GEN_BOX, list(-32, -32), list(32, 32), NORMAL_RAND)
					particleslist |= fs

			START_PROCESSING(SSprocessing, src)
			sound_token = sound_player.PlayLoopingSound(src, sound_id, 'sound/ambience/space_loop.ogg', volume = 75, range = 4, falloff = 0.5, prefer_mute = TRUE, ignore_vis = TRUE)
			overlays += "redbanner"
			currentfaction = RED_TEAM
		else
			for(var/turf/simulated/floor/T in view(range, src))
				if(!istype(T, /turf/simulated/open))
					set_light(4, 1, "#80aeee")
					T.color = "#e7f4ff"
					var/obj/particle_emitter/fire_sparks/fs = new(T)
					fs.particles.count = 4
					fs.particles.fade = 3
					fs.particles.lifespan = 3
					fs.particles.position = generator(GEN_BOX, list(-32, -32), list(32, 32), NORMAL_RAND)
					fs.particles.gradient = list(0, "cyan", 1, "blue")
					fs.particles.color = "blue"
					particleslist |= fs
			START_PROCESSING(SSprocessing, src)
			sound_token = sound_player.PlayLoopingSound(src, sound_id, 'sound/ambience/space_loop.ogg', volume = 75, range = 4, falloff = 0.5, prefer_mute = TRUE, ignore_vis = TRUE)
			overlays += "bluebanner"
			currentfaction = BLUE_TEAM

/obj/structure/factionbanner/New() // I PROMISE this makes it look nicer
	. = ..()
	pixel_x = rand(0,6)
	pixel_y = rand(-4,-6)
	sound_id = "[type]_[sequential_id(type)]"

/obj/structure/factionbanner/attack_hand(mob/living/user)
	. = ..()
	if(CanPhysicallyInteract(user))
		if(progress<4 && progress>0 && !user.doing_something)
			user.doing_something = TRUE
			if(do_after(user, 45)) // I like odd numbers
				progress++
				playsound(src.loc, "sound/effects/teleextend[progress].ogg", 85, 1)
				update_icon()
				lastuser = user
				user.doing_something = FALSE
				return
			else
				user.doing_something = FALSE
				return

/obj/structure/factionbanner/RightClick(mob/living/user)
	. = ..()
	if(CanPhysicallyInteract(user))
		if(progress==1 && !user.doing_something)
			user.doing_something = TRUE
			if(do_after(user, 60))
				playsound(src.loc, "sound/effects/teleretract[progress].ogg", 85, 1)
				user.doing_something = FALSE
				new /obj/item/melee/classic_baton/factionbanner(loc)
				qdel(src)
				return
			else
				user.doing_something = FALSE
				return
		if(progress<=4 && progress>0 && !user.doing_something)
			user.doing_something = TRUE
			if(do_after(user, 30))
				progress--
				update_icon()
				playsound(src.loc, "sound/effects/teleretract[progress].ogg", 85, 1)
				lastuser = user
				user.doing_something = FALSE
				set_light(0, 0, 0)
				for(var/turf/T in view(range, src))
					if(!istype(T, /turf/simulated/open))
						T.color = initial(T.color)
				for(var/obj/particle_emitter/fire_sparks/fs in particleslist)
					qdel(fs)
				if(is_processing)
					STOP_PROCESSING(SSprocessing, src)
				return
			else
				user.doing_something = FALSE
				return

/obj/structure/factionbanner/examine(mob/user, distance, infix, suffix)
	. = ..()
	if(user.warfare_faction == currentfaction)
		to_chat(user, "<h2>This is your flag! Go [user.warfare_faction]!</h2>")

/obj/structure/factionbanner/Process()
	if(locate(/obj/effect/effect/smoke, get_turf(src))) // if it got smokebombed, no worky 100%
		return // whatever shitty way to do it
	for(var/mob/living/carbon/human/H in view(world.view, src)) // for gameplay balance, smoke grenades disrupt the banner's effect.
		if(H.warfare_faction == currentfaction)
			if(get_dist(H, src) <= range)
				H.add_event("banner boost", /datum/happiness_event/banner_boost) // YOU ARE SAD, YOU ARE HAPPY, YOU ARE sad // Please fix.. i dont like the spam..
				// if you cant fix it, stuff, make it give some other kind of boost maybe? idk.. like pain tolerance or smth?
		else
			H.add_event("banner deboost", /datum/happiness_event/banner_deboost)

/obj/item/melee/classic_baton/factionbanner
	name = "Flagpole"
	desc = "Use it to place your faction's flagpole in front of you. Show them what you're really fighting for!<br>Also doubles as a melee weapon, cool!"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "flagpole"
	item_state = "telebaton_0"
	w_class = ITEM_SIZE_NORMAL // It's foldable.. but still!
	force = 7
	block_chance = 10

/obj/item/melee/classic_baton/factionbanner/attack_self(mob/living/user)
	if(CanPhysicallyInteract(user))
		var/turf/simulated/floor/T = get_step(user, user.dir)
		if(T && !user.doing_something)
			if(isopenspace(T))
				return
			/*if(!istype(get_area(T), /area/warfare/battlefield/no_mans_land))
				to_chat(user, "<b>I should only place this in the no man's land!</b>")*/
			if(turf_contains_dense_objects(T) || iswall(T)) //no 20 structures of barbed wire in one tile/in walls
				to_chat(H, "There's already something there!")
				return
			visible_message("[user] begins to place the faction banner!")
			user.doing_something = TRUE
			if(do_after(user, 60))
				playsound(T, "sound/effects/teleextend[rand(2,3)].ogg", 85, 1)
				user.doing_something = FALSE
				qdel(src)
				new /obj/structure/factionbanner(T)
			else
				user.doing_something = FALSE
				return

/obj/structure/warfare/thehatch
	name = "the hatch"
	desc = "\"The dead are to be put into this, as it is my decree.\"\n\"Then you are to knock on this here door.. twice.. no more, no less..\"\n\"And then, you shall wait for the confirmation..\""
	icon = 'icons/obj/objects.dmi'
	icon_state = "hatchframe"
	anchored = TRUE
	plane = ABOVE_HUMAN_PLANE
	layer = ABOVE_HUMAN_LAYER
	var/open
	var/busy
	var/obj/structure/warfare/tray/tray // instead of deleting and adding it, we can re-use the same tray object :>
	var/mob/living/carbon/human/inside
	var/obj/item/stack/teeth/other_stuff_inside
	var/goredinside

/obj/structure/warfare/thehatch/New()
	update_icon()
	tray = new(src)
	//var/direction
	//switch(dir)
	//	if(NORTH)
	//		direction = SOUTH
	//	if(SOUTH)
	//		direction = NORTH
	//if(!direction)
	//direction = dir
	//tray.set_dir(direction)
	tray.set_dir(dir)
	tray.hatch = src

/obj/structure/warfare/thehatch/update_icon()
	. = ..()
	overlays.Cut()
	if(!open)
		var/image/hatch = image(icon=src.icon,icon_state="hatch")
		overlays += hatch

/obj/structure/warfare/thehatch/attack_hand(mob/user)
	if(CanPhysicallyInteract(user))
		toggle()

/obj/structure/warfare/thehatch/proc/toggle()
	if(busy)
		return
	if(!open)
		busy = TRUE
		open = TRUE
		update_icon()
		playsound(src, 'sound/effects/thehatch.ogg', 75, 0.25)
		sleep(3)
		playsound(get_step(src, dir), 'sound/effects/thetray.ogg', 75, 0.25)
		sleep(2)
		tray.forceMove(get_step(src, dir))
		if(inside)
			inside.forceMove(get_turf(tray)) // aww..
			inside = null
		if(other_stuff_inside)
			other_stuff_inside.forceMove(get_turf(tray))
			other_stuff_inside = null
		if(goredinside)
			new/obj/effect/gibspawner/human(get_turf(tray))
			goredinside = FALSE
		// sound 2
		busy = FALSE
	else
		busy = TRUE
		// sound1
		var/list/people = list() // let's make it a fair lottery..
		for(var/mob/living/carbon/human/H in get_turf(tray))
			//if(H.stat == DEAD)
			people |= H
			continue
		inside = safepick(shuffle(people)) // shuffle them around..
		tray.forceMove(src)
		playsound(get_turf(tray), 'sound/effects/thetrayin.ogg', 75, 0.25)
		if(inside)
			inside.forceMove(src) // yay you're going home!!
		sleep(5)
		playsound(src, 'sound/effects/thehatchin.ogg', 75, 0.25)
		// sound 2
		open = FALSE
		busy = FALSE
		update_icon()

/obj/structure/warfare/thehatch/RightClick(mob/living/carbon/human/user)
	if(busy)
		return
	if(open)
		return
	if(user == inside)
		return
	if(CanPhysicallyInteract(user))
		busy = TRUE
		if(do_after(user, 20))
			user.visible_message("[user] knocks on the door..", "You knock on the door..")
			playsound(get_turf(user), 'sound/effects/hatchknock.ogg',75,0.5)
			sleep(3)
			playsound(get_turf(user), 'sound/effects/hatchknock.ogg',75,0.5)
			if(inside)
				var/total_teeth = 0
				for(var/obj/item/organ/O in inside.organs)
					if(O.status & ORGAN_CUT_AWAY)
						continue
					else
						if(istype(O, /obj/item/organ/external))
							if(istype(O, /obj/item/organ/external/head/))
								var/obj/item/organ/external/head/H = O
								total_teeth += H.get_teeth()
							total_teeth += 1
							continue
						else
							total_teeth += 2
							continue
				other_stuff_inside = new/obj/item/stack/teeth/human()
				other_stuff_inside.amount = total_teeth
				other_stuff_inside.update_icon()
				if(inside.stat == DEAD)
					sleep(rand(20,40))
					playsound(get_turf(src), 'sound/effects/hatchknock.ogg',35,0.25, override_env = SEWER_PIPE)
					sleep(6)
					playsound(get_turf(src), 'sound/effects/hatchknock.ogg',35,0.25, override_env = SEWER_PIPE)
					qdel(inside)
					inside = null
					busy = FALSE
				else
					sleep(rand(15,30))
					playsound(get_turf(src), 'sound/effects/hatched.ogg', 90, 0, override_env = SEWER_PIPE)
					sleep(110)
					inside.death()
					inside.ghostize(FALSE)
					qdel(inside)
					inside = null
					goredinside = TRUE
					playsound(get_turf(src), 'sound/effects/hatchknock.ogg',35,0.25, override_env = SEWER_PIPE)
					sleep(6)
					playsound(get_turf(src), 'sound/effects/hatchknock.ogg',35,0.25, override_env = SEWER_PIPE)
					busy = FALSE
			else
				busy = FALSE
				return
		else
			busy = FALSE


/obj/structure/warfare/tray/
	icon = 'icons/obj/objects.dmi'
	icon_state = "hatchtray"
	density = TRUE
	anchored = TRUE
	var/obj/structure/warfare/thehatch/hatch

/obj/structure/warfare/tray/attack_hand(mob/user)
	. = ..()
	hatch.toggle()

/obj/structure/warfare/tray/MouseDrop_T(var/mob/target, var/mob/user)
	if(!CanPhysicallyInteract(user))
		return
	if(target.loc == get_turf(src))
		return // eugh
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/murderer
	if(ishuman(user))
		murderer = user
		murderer.doing_something = TRUE
	if(do_after(user, 30))
		density = FALSE
		step_towards(target, src)
		density = TRUE
		murderer.doing_something = FALSE
	else
		murderer.doing_something = FALSE
