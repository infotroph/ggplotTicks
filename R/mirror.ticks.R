axgrep = function(gtab, pattern){
	# Helper, not exported: Find grobs with pattern in their grobnames.
	# These are not necessarily the same grobs returned by
	# gtable_filter(gtab, pattern)!
	which(sapply(gtab$grobs, function(x)grepl(pattern, x$name)))
}

match.axes = function(panel, extents){
	# Helper, not exported: Find the existing bottom and left axes
	# that apply to this panel, even if they're in a different panel.

	# *left* axes in same row have same *bottom* extent,
	# *bottom* axes in same column have same *left* extent.
	lax =  which(extents$b == panel$b & !extents$isnull)
	bax = which(extents$l == panel$l & !extents$isnull)

	if(length(lax) > 1){
		# Multiple axes in this row, e.g. facet_wrap(..., scales="free_x") => use only this panel's axes.
		lax = which(extents$b == panel$b & extents$l == panel$l-1)
	}
	if(length(bax) > 1){
		# Multiple axes in this col, e.g. facet_wrap(..., scales="free_y")
		bax = which(extents$l == panel$l & extents$b == panel$b+1)
	}

	if(length(lax) == 1 && length(bax) == 1){
		return(c(lax[[1]], bax[[1]]))
	}else{
		stop(paste("Can't match axes to", panel$name))
	}
}

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
		cur_axes = match.axes(cur_panel, axis_extents)

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

		if(allPanels==TRUE){
			if(!is_rowstart[i]){
				lax = axes$grobs[[cur_axes[1]]]
				ltxt = axgrep(lax$children$axis, "text")
				lax$children$axis$grobs[[ltxt]]$label = NULL
			}else{
				lax=grob(name=NULL)
				class(lax) = c("zeroGrob", class(lax))
			}

			if(!is_colbottom[i]){
				botax = axes$grobs[[cur_axes[2]]]
				bottxt = axgrep(botax$children$axis, "text")
				botax$children$axis$grobs[[toptxt]]$label = NULL
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
				name=c("axis-ll", "axis-bb"))
		}
	}
	return(ggobj)
}
