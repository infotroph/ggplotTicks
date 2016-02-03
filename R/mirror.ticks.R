# Takes a rendered ggplot2 axis grob and returns a copy
# with labels removed and ticks reversed in direction xy,
# ready to add to the other side of the original panel.
#
# Beware: Relies heavily on internal plot structure!
# Known assumptions:
#	1. `axGrob` is an absoluteGrob with exactly one child named `axis`.
#		(Children with other names are OK and will be copied with no change)
#	2. `axis` is a gtable containing:
#		2a. Exactly one grob whose name contains "axis.text", which will be removed,
#		2b. and exactly one grob whose name contains "axis.ticks", which will be mirrored.
#		(Grobs with other names are OK and will be copied with no change)
#	4. The tick grob has class `polyline` or equivalent:
#		A list containing tick coordinates in components named `x` and `y`,
#		both with class `unit.list`.
#	5. The unit.list to be swapped has entries that alternate between
#		5a. the starting point of the tick, with class `unit`,
#		5b. and the ending point as a difference from start, with class `unit.arithmetic`.
#		(This format is mandatory. swaptick() works directly on unit.arithmetic objects,
#		so precomputed end coordinates will not work.)
#
# Will need to rewrite this if (when?) ggplot converts facets to ggproto objects.
mirror_axis = function(axGrob, xy=NULL){
	a = axGrob$children$axis

	txt_idx = grep_grobnames(a, "axis.text")
	a$grobs[[txt_idx]] = zeroGrob()

	if(!is.null(xy)){
		tick_idx = grep_grobnames(a, "axis.ticks")
		tt = a$grobs[[tick_idx]][[xy]]
		tt = swap_ticklist(tt)
		a$grobs[[tick_idx]][[xy]] = tt
	}

	axGrob$children$axis = a
	axGrob
}

# Takes a ggplot2 or gtable object, iterates through all panels mirroring axes.
# If allPanels=FALSE, just put axes on both ends of each row/column.
# If allPanels=TRUE, also add ticks to every edge of every panel --
#	this probably only makes sense if you set a large between-panel space.
#
# Returns a gtable, NOT a ggplot object.
mirror.ticks = function(ggobj, allPanels=FALSE){

	if(!is.gtable(ggobj)){
		ggobj = ggplotGrob(ggobj)
	}

	panel_extents = gtable_filter(ggobj, "panel", trim=FALSE)$layout

	# Logical vectors: Find outside edges of each row & column,
	# allowing for incomplete rows (e.g. 5 panels in 2 rows)
	is_coltop = mapply(
		FUN=function(bot,left){
			bot == min(panel_extents$b[panel_extents$l==left])},
		bot=panel_extents$b,
		left=panel_extents$l)
	is_colbottom = mapply(
		FUN=function(bot,left){
			bot==max(panel_extents$b[panel_extents$l==left])},
		bot=panel_extents$b,
		left=panel_extents$l)
	is_rowstart = mapply(
		FUN=function(bot,left){
			left == min(panel_extents$l[panel_extents$b==bot])},
		bot=panel_extents$b,
		left=panel_extents$l)
	is_rowend = mapply(
		FUN=function(bot,left){
			left == max(panel_extents$l[panel_extents$b==bot])},
		bot=panel_extents$b,
		left=panel_extents$l)

	# If the bottom panel of a column has no x-axis to mirror, add one.
	# Assumptions:
	#	* Panel numbers go from 1 to nrow(panel_extents).
	#	* Last panel will always have an x-axis to copy from, because it's always on the bottom row.
	#	* All panels have the same x-axis scale, because ggplot doesn't generate missing axes when scales differ.
	colbottom_names = paste0("axis_b", which(is_colbottom))
	missing_x = sapply(
		X=ggobj$grobs[colbottom_names],
		FUN=function(x)any(class(x) == "zeroGrob"))
	ggobj$grobs[colbottom_names[missing_x]] = list(ggobj$grobs[[paste0("axis_b", nrow(panel_extents))]])

	axes = gtable_filter(ggobj, "axis", trim=FALSE)
	axis_extents = axes$layout
	axis_extents$isnull = sapply(axes$grobs, function(x)any(class(x) == "zeroGrob"))

	for(i in 1:nrow(panel_extents)){

		if(allPanels==FALSE && !is_coltop[i] && !is_rowend[i]){
			# no mirroring to do in this panel, bail now
			next
		}

		cur_panel = panel_extents[i,]
		cur_axes = match_axes(cur_panel, axis_extents)

		if(allPanels==TRUE || is_rowend[i]){
			rtax = mirror_axis(axes$grobs[[cur_axes[1]]], xy="x")
			rtax$name = paste0(rtax$name, "-right-", i)
		}else{
			rtax=grob(name=NULL)
			class(rtax) = c("zeroGrob", class(rtax))
		}

		if(allPanels==TRUE || is_coltop[i]){
			topax = mirror_axis(axes$grobs[[cur_axes[2]]], xy="y")
			topax$name = paste0(topax$name, "-top-", i)
		}else{
			topax=grob(name=NULL)
			class(topax) = c("zeroGrob", class(topax))
		}

		ggobj = gtable_add_grob(
			x=ggobj,
			grobs=list(rtax, topax),
			t=cur_panel$t,
			l=cur_panel$l,
			r=cur_panel$r,
			b=cur_panel$b,
			z=cur_panel$z,
			name=paste0(c("axis-r-", "axis-t-"), i))

		if(allPanels==TRUE){
			if(!is_rowstart[i]){
				lax = mirror_axis(axes$grobs[[cur_axes[1]]], xy=NULL)
				lax$name = paste0(lax$name, "-left-", i)
			}else{
				lax=grob(name=NULL)
				class(lax) = c("zeroGrob", class(lax))
			}

			if(!is_colbottom[i]){
				botax = mirror_axis(axes$grobs[[cur_axes[2]]], xy=NULL)
				botax$name = paste0(botax$name, "-bottom-", i)
			}else{
				botax=grob(name=NULL)
				class(botax) = c("zeroGrob", class(botax))
			}

			ggobj = gtable_add_grob(
				x=ggobj,
				grobs=list(lax, botax),
				t=cur_panel$t + c(0, 1),
				l=cur_panel$l - c(1, 0),
				r=cur_panel$r - c(1, 0),
				b=cur_panel$b + c(0, 1),
				z=cur_panel$z,
				name=paste0(c("axis-ll-", "axis-bb-"), i))
		}
	}
	return(ggobj)
}
