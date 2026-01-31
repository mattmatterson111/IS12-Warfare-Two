
/obj/effect/map_entity/fire_pit
	name = "Great Fire Pit"
	desc = "A massive pit of roiling flames. It seems hungry for more than just wood."
	icon = 'icons/effects/fire.dmi'
	icon_state = "red_2"
	anchored = TRUE
	density = FALSE
	opacity = FALSE

	light_range = 12
	light_power = 12
	light_color = "#ff7755"
	var/faction_id = null

/obj/effect/map_entity/fire_pit/Initialize()
	. = ..()
	set_light(light_range, light_power, light_color)

/obj/effect/map_entity/fire_pit/attackby(obj/item/I, mob/user)
	if(istype(I))
		burn_object(I, user)
		return TRUE
	return ..()

/obj/effect/map_entity/fire_pit/Crossed(atom/movable/AM)
	if(istype(AM, /obj/item) || istype(AM, /obj/structure/closet/crate))
		burn_object(AM)
	else if(isliving(AM))
		burn_mob(AM)
	return ..()

/obj/effect/map_entity/fire_pit/proc/burn_mob(mob/living/L)
	if(!L || L.on_fire)
		return

	L.adjust_fire_stacks(25)
	L.IgniteMob()
	to_chat(L, SPAN_DANGER("You step into the [src] and catch fire!"))

/obj/effect/map_entity/fire_pit/hitby(atom/movable/AM)
	if(istype(AM, /obj/item))
		burn_object(AM)
	return ..()

/obj/effect/map_entity/fire_pit/proc/burn_object(atom/movable/AM, mob/user = null)
	if(!AM || QDELETED(AM)) return

	IO_output("fire_pit:OnBurn", user, src)

	if(user && istype(AM, /obj/item))
		user.drop_item()
	
	qdel(AM)
	do_feedback()

/obj/effect/map_entity/fire_pit/proc/do_feedback()
	playsound(src,get_sfx("flamer_fire"), 50, 1)