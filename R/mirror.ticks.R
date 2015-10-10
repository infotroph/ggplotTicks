mirror.ticks = function(ggobj){
	# Given a one-panel ggplot object with axes on the bottom and left,  
	# add matching axes on the top and right.
	# TODO: Make work with multi-panel plots by passing in panel number
	# 	(panel-1, panel-2, etc). Note "axis_l-1" vs 1-panel "axis-l").

	ggobj = ggplotGrob(ggobj)

	panel.extents = gtable_filter(ggobj, "panel", trim=FALSE)$layout

	rtax = gtable_filter(ggobj, "axis-l")$grobs[[1]]
	topax = gtable_filter(ggobj, "axis-b")$grobs[[1]]

	axgrep = function(gtab, pattern){
			which(sapply(gtab$grobs, function(x)grepl(pattern, x$name)))}

	rttxt = axgrep(rtax$children$axis, "text")
	toptxt = axgrep(topax$children$axis, "text")
	rttick = axgrep(rtax$children$axis, "ticks")
	toptick = axgrep(topax$children$axis, "ticks")

	rtax$children$axis$grobs[[rttxt]]$label = NULL
	topax$children$axis$grobs[[toptxt]]$label = NULL

	# Tick coordinates are encoded as 1npc for the end on the axis line 
	# 	and 1npc-axis.tick.length for the other end. 
	# We'll move ticks to the other side of the line by flipping the sign
	# 	of the subtraction.
	swaptick = function(tick){
		if(inherits(tick, "unit.arithmetic")){
			tick[[3]] = unit(
				-c(tick[[3]]), # drop unit class and invert bare numeric values
				attr(tick[[3]], "unit")) # add original unit class back on
			return(tick)
		} else {
			return(tick)
		}
	}

	rtax.x = rtax$children$axis$grobs[[rttick]]$x 
	rtax.x = sapply(rtax.x, swaptick, simplify=FALSE)
	class(rtax.x) = c("unit.list", "unit")
	rtax$children$axis$grobs[[rttick]]$x = rtax.x
	
	topax.y = topax$children$axis$grobs[[toptick]]$y 
	topax.y = sapply(topax.y, swaptick, simplify=FALSE)
	class(topax.y) = c("unit.list", "unit")
	topax$children$axis$grobs[[toptick]]$y = topax.y

	ggobj = gtable_add_grob(
		x=ggobj, 
		grobs=list(rtax, topax), 
		t=panel.extents$t,
		l=panel.extents$l,
		r=panel.extents$r,
		b=panel.extents$b, 
		z=panel.extents$z, 
		name=c("axis-r", "axis-t"))
	return(ggobj)
}
