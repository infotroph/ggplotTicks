# Add tick-mirroring to a ggplot object.
# (Actually just subclass it so that the mirroring will happen at render time.)
mirror_ticks = function(ggobj, allPanels=FALSE){
	tcl = if(allPanels==TRUE){ "ggTicksAll" }else{ "ggTicks" }
	class(ggobj$facet) = c(tcl, class(ggobj$facet))
	ggobj
}


# S3 methods to be picked up by the ggplot2::facet_render generic
facet_render.ggTicks = function(...){
	mirror_gtable(NextMethod("facet_render"))
}

facet_render.ggTicksAll = function(...){
	mirror_gtable(NextMethod("facet_render"), allPanels=TRUE)
}
