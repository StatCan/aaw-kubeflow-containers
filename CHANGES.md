# Two renames

r-notebook -> geospatial-notebook
Since every image has R now


tensorflow -> machine-learning

# Split up minimal into minimal+base

I thought it might be good to differentiate the CPU/GPU configuration (done in base)
with the software configuration done in minimal.

It might make it simpler to keep the cpu and gpu branches in sync if the diff at the minimal
layer is only one line by default. We can evolve the minimal config while hiding the complexity
in the `base` image, which will hopefully remain pretty static.
