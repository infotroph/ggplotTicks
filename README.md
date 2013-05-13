ggplot-ticks
============

Put scale ticks on all four sides on a ggplot by copying axes from bottom to top and left to right sides.


Think of this as a replacement for the panel grid, not a way of adding multiple scales to the same plot. 

Note that this function converts the plot from a ggplot object to a gtable, 
so build the whole plot first and then call mirror-ticks as the last transformation before plotting.

Note that mirror-ticks doesn't (yet) handle multi-panel plots. This will be my next step.
