// Okay so basically
// to animate it, you do

// var/atom/movable/a = objname.get_vis(1) 
// THE INDEX IS THE NUMBER OF THE OBJ, THEY GET ADDED IN ORDER OF THE INPUT LIST (OR VIS_CHILDREN SUBYPE) ORDER!
// animate(a, ...)
// OK :thumbs_up

/obj/screen/visparent
	var/list/vis_children = list()

/obj/screen/visparent/New(var/list/types)
    . = ..()
    if(vis_children.len && !types.len)
        types = vis_children
    if(types.len)
        for(var/type in types)
            var/atom/movable/child = new type(src)
            vis_children.Add(child)

/obj/screen/visparent/Destroy()
    for(var/atom/a in vis_children)
        qdel(a)
    . = ..()

/obj/screen/visparent/proc/add_vis(atom/movable/AM)
	if(!AM || (AM in vis_children))
		return
	vis_children += AM
	vis_contents += AM

/obj/screen/visparent/proc/remove_vis(atom/movable/AM)
	if(!AM || !(AM in vis_children))
		return
	vis_children -= AM
	vis_contents -= AM

/obj/screen/visparent/proc/clear_vis()
	for(var/atom/movable/AM in vis_children)
		vis_contents -= AM
	vis_children.Cut()

/obj/screen/visparent/proc/get_vis(var/index)
	for(var/atom/movable/AM in vis_children)
		if(vis_children[index])
			return AM
	return null
