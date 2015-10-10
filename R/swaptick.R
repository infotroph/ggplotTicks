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