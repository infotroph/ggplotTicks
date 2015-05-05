mirror.ticks = function(ggobj, allPanels=FALSE){
	# Given a ggplot object with axes on the bottom and left, 
	# add matching axes on the top and right.
	# For a multipanel figure: 
	# if allPanels=F, mirrors ticks to the other end of the row/column. 
	# allPanels=T *not yet implemented*, 
	# when done it will mirror ticks from B->T and L->R within EACH panel...
	# But think about whether that's really what you want! 
	# The last thing most multipanel plots need is more tick marks.

	require(gtable)
	
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
		}else if(length(lax) == 1 && length(bax) == 1){
			return(c(lax[[1]], bax[[1]]))
		}else{
			stop(paste("Can't match axes to", panel$name))
		}	
	}

	ggobj = ggplotGrob(ggobj)

	panel_extents = gtable_filter(ggobj, "panel", trim=FALSE)$layout

	# Find outside edges of each row & column,
	# allowing for incomplete rows (e.g. 5 panels in 2 rows)
	is_coltop = mapply(
		FUN=function(bot,left){
			bot == min(panel_extents$b[panel_extents$l==left])},
		bot=panel_extents$b,
		left=panel_extents$l)
	is_rowend = mapply(
		FUN=function(bot,left){
			left == max(panel_extents$l[panel_extents$b==bot])},
		bot=panel_extents$b,
		left=panel_extents$l)


	axes = gtable_filter(ggobj, "axis", trim=FALSE)
	nulls = sapply(axes$grobs, function(x)any(class(x) == "zeroGrob"))
	axis_extents = axes$layout

	for(i in 1:nrow(panel_extents)){
		
		if(allPanels==FALSE && !is_coltop[i] && !is_rowend[i]){
			# no mirroring to do in this panel, bail now
			next
		}

		cur_panel = panel_extents[i,]
		cur_axes = match.axes(cur_panel)
		
		if(allPanels==TRUE || is_rowend[i]){
			rtax = axes$grobs[[cur_axes[1]]]

			rttxt = axgrep(rtax$children$axis, "text")
			rtax$children$axis$grobs[[rttxt]]$label = NULL

			rttick = axgrep(rtax$children$axis, "ticks")
			rtax_x = rtax$children$axis$grobs[[rttick]]$x
			rtax_x = sapply(rtax_x, swaptick, simplify=FALSE)
			class(rtax_x) = c("unit.list", "unit")
			rtax$children$axis$grobs[[rttick]]$x = rtax_x
		}else{
			rtax=grob(name=NULL)
			class(rtax) = c("zeroGrob", class(rtax))
		}

		if(allPanels==TRUE || is_coltop[i]){
			topax = axes$grobs[[cur_axes[2]]]

			toptxt = axgrep(topax$children$axis, "text")
			topax$children$axis$grobs[[toptxt]]$label = NULL
			
			toptick = axgrep(topax$children$axis, "ticks")
			topax_y = topax$children$axis$grobs[[toptick]]$y
			topax_y = sapply(topax_y, swaptick, simplify=FALSE)
			class(topax_y) = c("unit.list", "unit")
			topax$children$axis$grobs[[toptick]]$y = topax_y
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
			name=c("axis-r", "axis-t"))
	}
	return(ggobj)
}
