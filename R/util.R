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
