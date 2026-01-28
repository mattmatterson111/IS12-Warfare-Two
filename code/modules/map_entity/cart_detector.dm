// Trigger entity that detects Payloads
/obj/effect/map_entity/cart_detector
	name = "cart_detector"
	icon_state = "trigger"
	is_brush = TRUE
	var/filter_faction = null

/obj/effect/map_entity/cart_detector/Crossed(atom/movable/AM)
	. = ..()
	if(!enabled)
		return
	if(!istype(AM, /obj/structure/payload))
		return
	
	if(filter_faction)
		var/obj/structure/payload/P = AM
		if(P.warfare_faction != filter_faction)
			return

	fire_output("OnTrigger", AM, src)

/obj/effect/map_entity/cart_detector/Uncrossed(atom/movable/AM)
	. = ..()
	if(!enabled)
		return
	if(!istype(AM, /obj/structure/payload))
		return
		
	if(filter_faction)
		var/obj/structure/payload/P = AM
		if(P.warfare_faction != filter_faction)
			return

	fire_output("OnTriggerEnd", AM, src)

/obj/effect/map_entity/cart_detector/red
	name = "cart_detector_red"
	filter_faction = RED_TEAM

/obj/effect/map_entity/cart_detector/blue
	name = "cart_detector_blue"
	filter_faction = BLUE_TEAM
