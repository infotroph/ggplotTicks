mirror.ticks = function(ggobj){
	# Given a one-panel ggplot object with axes on the bottom and left,  
	# add matching axes on the top and right.
	# TODO: Make work with multi-panel plots by passing in panel number
	# 	(panel-1, panel-2, etc). Note "axis_l-1" vs 1-panel "axis-l").

	require(gtable)
	
	ggobj = ggplotGrob(ggobj)

	axgrep = function(gtab, pattern){
			which(sapply(gtab$grobs, function(x)grepl(pattern, x$name)))}

	swaptick = function(tick){
	# Tick coordinates are encoded as 1npc for the end on the axis line 
	# 	and 1npc-axis.tick.length for the other end. 
	# We'll move ticks to the other side of the line by flipping the sign
	# 	of the subtraction.
		if(inherits(tick, "unit.arithmetic")){
			tick[[3]] = unit(
				-c(tick[[3]]), # drop unit class and invert bare numeric values
				attr(tick[[3]], "unit")) # add original unit class back on
			return(tick)
		} else {
			return(tick)
		}
	}

	match.axes = function(panel){
		# Find *left* axes in same row by matching *bottom* extent, 
		# find *bottom* axes in same column by matching *left* extent.
		lax =  which(axis_extents$b == panel$b & !nulls)
		bax = which(axis_extents$l == panel$l & !nulls)
		

		# FIXME: How to efficiently handle all these cases?
		# 1 panel bl->bltr
		# multipanel shared axes -> mirror to other end of row/col
		# multipanel axes differ -> mirror to... same panel?

		# may be able to assume null axes -> treat as same across row/col

		if(length(lax) > 1 || length(bax) > 1){
			# Multiple axes in this row/col, e.g. facet_wrap(..., scales="free")
			# *should* be safe to handle lax>1 and bax>1 identically, right?
			lax = which(axis_extents$b == panel$b & axes$layout$l == panel$l-1)
			bax = which(axis_extents$l == panel$l & axes$layout$b == panel$b+1)
		}
		if(length(lax) == 1 && length(bax) == 1){
			return(c(lax[[1]], bax[[1]]))
		}else{
			stop("Can't match axes to panel!")
		}	
	}

	panel.extents = gtable_filter(ggobj, "panel", trim=FALSE)$layout
	is_toprow = (panel_extents$b == min(panel_extents$b))
	is_rtcol = (panel_extents$l == max(panel_extents$l))

	rtax = gtable_filter(ggobj, "axis-l")$grobs[[1]]
	topax = gtable_filter(ggobj, "axis-b")$grobs[[1]]

	rttxt = axgrep(rtax$children$axis, "text")
	toptxt = axgrep(topax$children$axis, "text")
	rttick = axgrep(rtax$children$axis, "ticks")
	toptick = axgrep(topax$children$axis, "ticks")

	rtax$children$axis$grobs[[rttxt]]$label = NULL
	topax$children$axis$grobs[[toptxt]]$label = NULL


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
