/obj/effect/decal/cleanable/bloodpool
	name = "bloodpool"
	desc = "A pool of blood, why would you have this?"
	gender = PLURAL //pool of blood refers to itself by zie xie or some shit those retards with colored hair make up
	density = 0
	anchored = 1
	icon = 'icons/effects/pool.dmi'
	icon_state = "pool1"
	blood_DNA = list()
	var/base_icon = 'icons/effects/pool.dmi'
	var/list/viruses = list()
	var/basecolor=COLOR_BLOOD_HUMAN // Color when wet.
	var/list/datum/disease2/disease/virus2 = list()
	var/stages = list(100,200,300,400)
	var/stop
	var/amount = 0

/obj/effect/decal/cleanable/bloodpool/reveal_blood()
	if(!fluorescent)
		fluorescent = 1
		basecolor = COLOR_LUMINOL
		update_icon()

/obj/effect/decal/cleanable/bloodpool/clean_blood()
	fluorescent = 0
	if(invisibility != 100)
		set_invisibility(100)
		STOP_PROCESSING(SSobj, src)
	..(ignore=1)

/obj/effect/decal/cleanable/bloodpool/hide()
	return

/obj/effect/decal/cleanable/bloodpool/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/decal/cleanable/bloodpool/Initialize()
	. = ..()
	update_icon()
	stop = world.time + 500 //in 50 seconds the pool of blood should be at max size
	stages[1] = stages[1] + world.time
	stages[2] = stages[2] + world.time
	stages[3] = stages[3] + world.time
	stages[4] = stages[4] + world.time

	START_PROCESSING(SSobj, src)


/obj/effect/decal/cleanable/bloodpool/Process()
	//sorry for the shitty yandare dev code, but its the only way without switches(broken) or maths(inneficient apparently)
	if(locate(/mob/living/carbon/human) in src.loc)
		if(world.time < stages[1])
			icon_state = "pool1"
			amount = 2
		else if(stages[1]>world.time && world.time<stages[2])
			icon_state = "pool2"
			amount = 4
		else if(stages[2]>world.time && world.time<stages[3])
			icon_state = "pool3"
			amount = 6
		else if(stages[3]>world.time && world.time<stages[4])
			icon_state = "pool4"
			amount = 8
		else if(stages[4]>world.time && world.time<stop)
			icon_state = "pool5"
			amount = 10
		else if(world.time>stop + 30)
			STOP_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)



/obj/effect/decal/cleanable/bloodpool/update_icon()
	if(basecolor == "rainbow") basecolor = get_random_colour(1)
	color = basecolor
	if(basecolor == SYNTH_BLOOD_COLOUR)
		SetName("oil")
		desc = "It's black and greasy."
	else
		SetName(initial(name))
		desc = initial(desc)



/obj/effect/decal/cleanable/bloodpool/Crossed(mob/living/carbon/human/perp)
	if (!istype(perp))
		return
	if(amount < 1)
		return

	var/obj/item/organ/external/l_foot = perp.get_organ(BP_L_FOOT)
	var/obj/item/organ/external/r_foot = perp.get_organ(BP_R_FOOT)
	var/hasfeet = 1
	if((!l_foot || l_foot.is_stump()) && (!r_foot || r_foot.is_stump()))
		hasfeet = 0
	if(perp.shoes && !perp.buckled)//Adding blood to shoes
		var/obj/item/clothing/shoes/S = perp.shoes
		if(istype(S))
			S.blood_color = basecolor
			S.track_blood = max(amount,S.track_blood)

	else if (hasfeet)//Or feet
		perp.feet_blood_color = basecolor
		perp.track_blood = max(amount,perp.track_blood)
	else if (perp.buckled && istype(perp.buckled, /obj/structure/bed/chair/wheelchair))
		var/obj/structure/bed/chair/wheelchair/W = perp.buckled
		W.bloodiness = 4

	perp.update_inv_shoes(1)
	amount--

