/obj/item/grenade_attachment
	name = "M88 'Kraken' Rifle Grenade"
	desc = "A grenade that can be fired from your rifle. Attach to the front and fire like usual."
	icon = 'icons/obj/grenade.dmi'
	icon_state = "grenade_attachment"
	w_class = ITEM_SIZE_SMALL
	var/obj/item/ammo_casing/grenade/grenade = /obj/item/ammo_casing/grenade/frag

/obj/item/grenade_attachment/Initialize()
	. = ..()
	grenade = new grenade(src)
	

/obj/item/grenade_attachment/proc/fire(var/obj/item/gun/launcher)
	if(!grenade)
		return null
	var/obj/item/projectile/P = grenade.expend()
	if(P)
		P.forceMove(get_turf(launcher))
	playsound(get_turf(launcher), "launcher_fire", 75, 1)
	return P
