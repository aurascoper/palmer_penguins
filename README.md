This project builds on research from the classification problems within penguins within the Palmer Penguins dataset.

This project builds on research from classification problems using the Palmer Penguins dataset.

Included is a gradient-based functor network map as a 3D display for penguin migrations and variability sourced from the `PalmerPenguins.jl` dataset and library.

## Requirements

To get started, install the following Julia packages:

```julia

using Pkg; Pkg.add("CSV", "DataFrames", "PalmerPenguins", "Statistics", "PooledArrays", "PlotlyJS", "Python" ### 
include("penguin_3dplot.jl")

Thereafter, your IDE should render the interactive plot.


To find out more about the original research, please reference:

   Horst AM, Hill AP, Gorman KB (2020). palmerpenguins: Palmer
   Archipelago (Antarctica) penguin data. R package version 0.1.0.
   https://allisonhorst.github.io/palmerpenguins/. doi:
   10.5281/zenodo.3960218.
 
   A BibTeX entry for LaTeX users is
 
   @Manual{,
     title = {palmerpenguins: Palmer Archipelago (Antarctica) penguin data},
     author = {Allison Marie Horst and Alison Presmanes Hill and Kristen B Gorman},
     year = {2020},
     note = {R package version 0.1.0},
     doi = {10.5281/zenodo.3960218},
     url = {https://allisonhorst.github.io/palmerpenguins/},
   }
