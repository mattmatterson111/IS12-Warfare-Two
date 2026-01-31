/mob/living
	var/has_trench_overlay = FALSE

/turf/simulated/floor/trenches
	name = "trench"
	icon = 'icons/turf/trenches_turfs.dmi'
	icon_state = "wood0"
	can_smooth = TRUE
	movement_delay = 0.5

/obj/structure/trench_wall
	icon = 'icons/obj/warfare.dmi'
	icon_state = "underground_trench"
	plane = ABOVE_TURF_PLANE
	layer = BELOW_OBJ_LAYER
	alpha = 255
	mouse_opacity = FALSE
	density = FALSE
	anchored = TRUE

/obj/structure/trench_wall/attackby(obj/item/O, mob/user)
	return

/obj/structure/trench_wall/bullet_act(obj/item/projectile/P, def_zone)
	return

/obj/structure/trench_wall/ex_act(severity)
	return

/obj/structure/trench_wall/sequel
	icon_state = "underground_trench_sequel"

/obj/structure/trench_wall/innercorners
	icon_state = "underground_trench_sequel_sequel"

/obj/effect/structure/trench/sides
	icon = 'icons/obj/warfare.dmi'
	icon_state = "underground_trench"
	alpha = 255
	mouse_opacity = FALSE

/obj/effect/floor_decal/trench/sides/sequel
	icon_state = "underground_trench_sequel"

/obj/effect/floor_decal/trench/sides/innercorners
	icon_state = "underground_trench_sequel_sequel"


/turf/simulated/floor/trenches/relativewall()
	var/junction = 0
	for(var/turf/simulated/floor/trenches/W in orange(src,1))
		if(abs(src.x-W.x)-abs(src.y-W.y))
			junction |= get_dir(src,W)
	icon_state = "wood[junction]"

/turf/simulated/floor/trenches/ex_act()//No blowing this up.
	return


/turf/simulated/floor/trenches/underground
	icon = 'icons/obj/warfare.dmi'
	icon_state = "trench_old"
	is_underground = TRUE
	color = "#b5acbcff"

/turf/simulated/floor/trenches/underground/Initialize()
	dir = pick(GLOB.alldirs)

/turf/simulated/floor/trenches/underground/relativewall()
	return

/turf/simulated/floor/trenches/underground/relativewall_neighbours()
	return

/turf/simulated/floor/trenches/Initialize()
	. = ..()
	relativewall_neighbours()



/turf/simulated/floor/trench
	icon = 'icons/obj/warfare.dmi'
	icon_state = "trench"
	name = "trench"
	movement_delay = 0.5
	has_coldbreath = TRUE
	var/can_be_dug = TRUE

/turf/simulated/floor
	var/add_mask = FALSE

/turf/simulated/floor/trench/fake
	atom_flags = null
	can_be_dug = FALSE

/turf/simulated/floor/trench/tough
	can_be_dug = FALSE

/turf/simulated/floor/trench/ex_act(severity)
	return

/turf/simulated/floor/trench/update_dirt()
	return	// Dirt doesn't doesn't become dirty

/turf/simulated/floor/trench/New()
	..()
	if(!(locate(/obj/effect/lighting_dummy/daylight) in src) && !(locate(/obj/effect/map_entity/environment_blocker) in src))
		new /obj/effect/lighting_dummy/daylight(src)
	dir = pick(GLOB.alldirs)
	update_icon()

///turf/simulated/floor/trench/attackby(obj/O, mob/living/user)
//	to_chat(user, "Init")
//	if(!CanPhysicallyInteract(user))
//		..()
//		return
//	var/obj/item/concretesack/C = user.get_active_hand()
//	if(!istype(C))
//		..()
//		return
//	to_chat(user, "type passed")
//	if(user.doing_something)
//		return
//	if(!can_be_dug)//No escaping to mid early.
//		return
//	playsound(src, 'sound/effects/dig_shovel.ogg', 50, 0)
//	visible_message("[user] begins filling in the trench!")
//	user.doing_something = TRUE
//	if(do_after(user, backwards_skill_scale(user.SKILL_LEVEL(engineering)) * 5))
//		ChangeTurf(/turf/simulated/floor/concrete)
//		update_trench_shit()
//		visible_message("[user] finishes filling in trench with concrete.")
//		playsound(src, 'sound/effects/empty_shovel.ogg', 50, 0)
//		user.doing_something = FALSE
//	else
//		user.doing_something = FALSE

/turf/simulated/floor/trench/RightClick(mob/living/user)
	var/obj/item/gun/G = user.get_active_hand()//Please let me aim, thanks.
	if(istype(G) && !G.safety)
		..()
		return

	if(!CanPhysicallyInteract(user))
		..()
		return
	var/obj/item/shovel/S = user.get_active_hand()
	if(!istype(S))
		..()
		return
	if(user.doing_something)
		return
	if(!can_be_dug)//No escaping to mid early.
		return
	if(src.density)
		return
	for(var/obj/structure/object in contents)
		if(istype(object, /obj/structure/landmine) || istype(object, /obj/structure/barbwire) || istype(object, /obj/structure/anti_tank))
			to_chat(user, "There are structures or landmines in the way.")
			return
	playsound(src, 'sound/effects/dig_shovel.ogg', 50, 0)
	visible_message("[user] begins filling in the trench!")
	user.doing_something = TRUE
	if(do_after(user, backwards_skill_scale(user.SKILL_LEVEL(engineering)) * 5))
		for(var/mob/M in src)
			if(ishuman(M))
				M.pixel_y = 0
		user.doing_something = FALSE
		ChangeTurf(/turf/simulated/floor/dirty)
		update_trench_shit()
		for(var/obj/structure/O in contents)
			qdel(O)
		visible_message("[user] finishes filling in the trench.")
		playsound(src, 'sound/effects/empty_shovel.ogg', 50, 0)

	else
		user.doing_something = FALSE
		to_chat(user, "You're already digging.")


/turf/simulated/floor/proc/update_trench_layers()
	vis_contents.Cut()
	for(var/direction in GLOB.cardinal)
		var/turf/turf_to_check = get_step(src,direction)
		if(istype(turf_to_check, /turf/simulated/floor/trench))
			continue
		if(istype(turf_to_check, /turf/space) || istype(turf_to_check, /turf/simulated/floor) || istype(turf_to_check, /turf/simulated/floor/exoplanet/water/shallow) || istype(turf_to_check, /turf/simulated/wall))
			var/atom/movable/trench_side = new()
			trench_side.icon = 'icons/obj/warfare.dmi'
			trench_side.icon_state = "trench_side"
			trench_side.dir = turn(direction, 180)
			trench_side.mouse_opacity = 0
			switch(direction)
				if(NORTH)
					trench_side.icon_state = "trench_side_but_north" // hacky..
					trench_side.dir = pick(GLOB.cardinal)
					trench_side.pixel_y += ((world.icon_size) - 22)
					trench_side.plane = PLATING_PLANE
					trench_side.layer = BELOW_DOOR_LAYER
				if(SOUTH)
					trench_side.pixel_y -= ((world.icon_size) - 16)
					trench_side.plane = ABOVE_OBJ_PLANE
					trench_side.layer = BELOW_DOOR_LAYER
				if(EAST)
					trench_side.pixel_x += (world.icon_size)
					trench_side.plane = ABOVE_OBJ_PLANE
					trench_side.layer = BASE_MOB_LAYER
				if(WEST)
					trench_side.pixel_x -= (world.icon_size)
					trench_side.plane = ABOVE_OBJ_PLANE
					trench_side.layer = BASE_MOB_LAYER
			vis_contents += trench_side


//Masks and overlays.
/obj/effect/trench/mask
	name = null
	mouse_opacity = FALSE
	icon = 'icons/obj/warfare.dmi'
	icon_state = "trench_mask"
	plane = HIDDEN_SHIT_PLANE
	appearance_flags = KEEP_APART | RESET_TRANSFORM
	vis_flags = VIS_UNDERLAY
	pixel_y = -21

/obj/effect/trench/mask/water
	icon_state = "watermask_temp"
	pixel_y = -19

/turf/simulated/floor/trench/update_icon()
	update_trench_shit()

/turf/simulated/floor/proc/update_trench_shit()
	for(var/direction in GLOB.cardinal)
		var/turf/turf_to_check = get_step(src,direction)
		if(istype(turf_to_check, /turf/simulated/floor/trench))//Rebuild our neighbors.
			var/turf/simulated/floor/trench/T = turf_to_check
			T.update_trench_layers()
			continue

	update_trench_layers()

/obj/structure/bridge
	name = "wooden bridge"
	icon = 'icons/obj/trench_bridge.dmi'
	icon_state = "trench_bridge1"
	plane = -12 // trenches are on -10 and humans are on -12 so this needs to be -11 to accomodate the longer sprite
	density = FALSE
	anchored = TRUE
	var/health = 100
	pixel_x = -6

/obj/structure/bridge/do_climb(mob/living/user, ignore_doafter)
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


/obj/item/bridge
	name = "wooden bridge"
	desc = "Place it above the trench"
	icon = 'icons/obj/items.dmi'
	icon_state = "trench_bridge"
	item_state = "trench_bridge"
	w_class = ITEM_SIZE_LARGE

/obj/structure/bridge/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/bridge/mapping
	health = 500
	pixel_x = 0
/obj/structure/bridge/mapping/RightClick(mob/user)
	return
/obj/structure/bridge/mapping/Process() // yay mapping!!
	return

/obj/structure/bridge/mapping/large
	icon = 'icons/obj/warfare.dmi'
	icon_state = "trench_bridge_large"

/obj/structure/bridge/mapping/bullet_act(var/obj/item/projectile/Proj)
	return

/obj/structure/bridge/mapping/ex_act(severity)
	return

/obj/structure/bridge/RightClick(mob/user)
	if(!CanPhysicallyInteract(user))
		return

	visible_message("[user] begins to dismantle the bridge!")
	if(do_after(user, 50))
		new /obj/item/bridge(src.loc)
		qdel(src)
		return

/obj/structure/bridge/bullet_act(var/obj/item/projectile/Proj)
	..()
	for(var/mob/living/carbon/human/H in loc)
		H.bullet_act(Proj)
	health -= rand(10, 25)
	if(health <= 0)
		visible_message("<span class='danger'>The [src] crumbles!</span>")
		playsound(src, 'sound/effects/wood_break1.ogg', 100)
		qdel(src)

/obj/structure/bridge/ex_act(severity)
	if(prob(85))
		playsound(src, 'sound/effects/wood_break1.ogg', 100)
		qdel(src)
		return


/obj/structure/bridge/Process() // If turfs near bridge change - drop bridge
	//  Horrific code begins
	if(src.dir == NORTH || src.dir == SOUTH)
		var/turf/NORTH_dirt = get_step(src,NORTH)
		var/turf/SOUTH_dirt = get_step(src,SOUTH)
		if(!istype(NORTH_dirt, /turf/simulated/floor/dirty) || !istype(SOUTH_dirt, /turf/simulated/floor/dirty))
			new /obj/item/bridge(src.loc)
			qdel(src)
			return

	else if(src.dir == WEST || src.dir == EAST)
		var/turf/WEST_dirt = get_step(src,WEST)
		var/turf/EAST_dirt = get_step(src,EAST)
		if(!istype(WEST_dirt, /turf/simulated/floor/dirty) || !istype(EAST_dirt, /turf/simulated/floor/dirty))
			new /obj/item/bridge(src.loc)
			qdel(src)
			return

/obj/structure/bridge/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/turf/simulated/floor/trench/attackby(obj/O as obj, mob/living/user as mob)
	if(istype(O, /obj/item/bridge))
		if(!user.doing_something)
			user.doing_something = TRUE
			for(var/obj/structure/object in contents)
				if(object)
					to_chat(user, "There are things in the way.")
					user.doing_something = FALSE
					return
			visible_message("[user] begins to place bridge!")


			//  Horrific code continues
			if(do_after(user, (backwards_skill_scale(user.SKILL_LEVEL(engineering)) * 5)))


				// Avoiding duplication
				var/turf_check = 0
				for(var/direction in GLOB.cardinal)
					var/turf/turf_to_check = get_step(src,direction)
					if(istype(turf_to_check, /turf/simulated/floor/dirty))
						turf_check++

				if(turf_check >= 4) // But still spawn only one bridge
					var/obj/structure/bridge/B = new(src)
					B.dir = pick(dir)
					playsound(src, 'sound/effects/extout.ogg', 100, 1)
					user.doing_something = FALSE
					qdel(O)
					return


				var/turf/NORTH_dirt = get_step(src,NORTH)
				var/turf/SOUTH_dirt = get_step(src,SOUTH)

				if(istype(NORTH_dirt, /turf/simulated/floor/dirty) && istype(SOUTH_dirt, /turf/simulated/floor/dirty))
					var/obj/structure/bridge/B = new(src)
					B.dir = pick(NORTH, SOUTH)
					qdel(O)
					playsound(src, 'sound/effects/extout.ogg', 100, 1)
				var/turf/WEST_dirt = get_step(src,WEST)
				var/turf/EAST_dirt = get_step(src,EAST)

				if(istype(WEST_dirt, /turf/simulated/floor/dirty) && istype(EAST_dirt, /turf/simulated/floor/dirty))
					var/obj/structure/bridge/B = new(src)
					B.dir = pick(WEST, EAST)
					qdel(O)
					playsound(src, 'sound/effects/extout.ogg', 100, 1)

			user.doing_something = FALSE
		else
			to_chat(user, "You're already placing bridge.")

/obj/structure/bridge/CanPass(atom/movable/mover, turf/target)
	var/mob/living/carbon/human/M = mover
	if(istype(M))
		if(M.plane == LYING_HUMAN_PLANE && M.crouching)
			return 1
		if(M.plane == HUMAN_PLANE)
			return 1
		if(M.lying)
			return 1
		else
			to_chat(M, "You need to crouch low to pass.")
			return 0
	else return 1

/atom/
	var/in_trench

/turf/simulated/floor/trench/Crossed(var/io)
	if(ishuman(io))
		var/mob/living/carbon/human/M = io
		//if(M.plane == HUMAN_PLANE && locate(/obj/structure/bridge, get_turf(src)))
		//	return
		if(locate(/obj/structure/trenchstairs, get_turf(src)))
			M.pixel_y = -4
			return
		if(!M.throwing)
			//if(M.client)
			//	M.fov_mask.screen_loc = "1,0.8"
			//	M.fov.screen_loc = "1,0.8"
			if(M.crouching)
				M.pixel_y = -12
			else
				M.pixel_y = -8

			M.reset_layer()
			M.plane = LYING_HUMAN_PLANE
			M.in_trench = 1 // Yes, we in trench now.

			if(add_mask)
				M.vis_contents += new /obj/effect/trench/mask
				M.has_trench_overlay = TRUE
				if(M.crouching)
					for(var/obj/effect/trench/mask/mask in M.vis_contents)
						mask.pixel_y = -18

			else if(!add_mask)
				if(M.has_trench_overlay)
					for(var/obj/effect/trench/mask/mask in M.vis_contents)
						M.vis_contents -= mask
						qdel(mask)
					M.has_trench_overlay = FALSE




			var/trench_check = 0 //If we're not up against a trench wall, we don't want to stay zoomed in.
			for(var/direction in GLOB.cardinal)
				var/turf/turf_to_check = get_step(M.loc,direction)//So get all of the turfs around us.
				if(istype(turf_to_check, /turf/simulated/floor/trench))//And if they're a trench, count it.
					trench_check++
			if(trench_check >= 4)//We're surrounded on all sides by trench. We unzoom.
				if(M.zoomed)//If we're zoomed that is.
					M.do_zoom()
	if(istype(io,/obj))
		var/obj/O = io
		if(O.pulledby) // for pulling stuff...
			O.in_trench = O.pulledby.in_trench
		//if(locate(/obj/structure/bridge, get_turf(src)) && !O.in_trench)
		//	O.plane = HUMAN_PLANE
		//	return
		O.in_trench = TRUE

/turf/simulated/floor/trench/Uncrossed(var/io)
	if(ishuman(io))
		var/mob/living/carbon/human/M = io
		//if(M.client)
		//	M.fov_mask.screen_loc = "1,1"
		//	M.fov.screen_loc = "1,1"
		M.in_trench = 0 // We leave the trench.
		M.pixel_y = 0
		M.plane = HUMAN_PLANE
		M.reset_layer()
		if(M.has_trench_overlay)
			for(var/obj/effect/trench/mask/mask in M.vis_contents)
				M.vis_contents -= mask
				qdel(mask)
	if(istype(io, /obj/))
		var/obj/O = io
		O.in_trench = FALSE
		O.plane = initial(O.plane)

/obj/item/concretesack
	name = "quickcrete mix"
	desc = "Mix, pour & wait!"
	icon = 'icons/obj/trash.dmi'
	icon_state = "trashbag2"