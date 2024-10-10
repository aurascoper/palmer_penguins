using CSV, DataFrames, PalmerPenguins, StatsBase, Clustering, CategoricalArrays, Statistics, PooledArrays, PlotlyJS

# Step 1: Load the Palmer Penguins dataset and drop missing values
penguins = dropmissing(DataFrame(PalmerPenguins.load()))

# Step 2: Check and convert numerical columns to Float64 if necessary
numeric_cols = [:flipper_length_mm, :bill_length_mm, :body_mass_g]
for col in numeric_cols
    if !(eltype(penguins[!, col]) <: AbstractFloat)
        penguins[!, col] = convert(Vector{Float64}, penguins[!, col])
    end
end

# Step 3: Convert categorical columns to standard `String` type if necessary
categorical_cols = [:species, :island]
for col in categorical_cols
    penguins[!, col] = String.(penguins[!, col])
end

# Step 4: Define colors for each island
island_colors = Dict(
    "Torgersen" => "red",
    "Biscoe" => "blue",
    "Dream" => "green"
)

# Step 5: Create separate traces for each island with distinct color and individual hover text
island_traces = PlotlyJS.GenericTrace[]  # Empty array for storing traces

for (island, color) in island_colors
    # Select data points corresponding to the current island
    island_data = penguins[penguins.island .== island, :]

    # Create individual hover text for each penguin using the appropriate columns
    hover_texts = [
        "Species: $(island_data.species[i])<br>" *
        "Island: $(island_data.island[i])<br>" *
        "Flipper Length: $(island_data.flipper_length_mm[i]) mm<br>" *
        "Bill Length: $(island_data.bill_length_mm[i]) mm<br>" *
        "Body Mass: $(island_data.body_mass_g[i]) g"
        for i in 1:nrow(island_data)
    ]

    # Create a 3D scatter trace for all penguins in the current island with individual hover texts
    trace = PlotlyJS.scatter3d(
        x = island_data.flipper_length_mm,
        y = island_data.bill_length_mm,
        z = island_data.body_mass_g,
        mode = "markers",
        marker = Dict(
            :size => 6,  # Marker size for data points
            :color => color  # Use predefined color for the island
        ),
        name = island,  # Island name for legend
        text = hover_texts,  # List of hover text strings for individual points
        hoverinfo = "text"  # Display only the custom hover text on interaction
    )

    # Append the trace to the list of island traces
    push!(island_traces, trace)
end

# Step 6: Define layout for the 3D plot with appropriate units in the axis labels
layout = PlotlyJS.Layout(
    title = "Interactive 3D Scatter Plot of Penguins by Island",
    scene = attr(
        xaxis = attr(title = "Flipper Length (mm)", showgrid = true, zeroline = false),  # X-axis with units
        yaxis = attr(title = "Bill Length (mm)", showgrid = true, zeroline = false),     # Y-axis with units
        zaxis = attr(title = "Body Mass (g)", showgrid = true, zeroline = false)         # Z-axis with units
    ),
    legend = attr(
        title = attr(text = "Island"),
        x = 0.85,  # Adjust position of the legend
        y = 1,
        bgcolor = "rgba(255, 255, 255, 0.5)"  # Semi-transparent white background for legend
    )
)

# Step 7: Combine scatter plot traces and layout using `PlotlyJS.plot`
plot_figure = PlotlyJS.plot(PlotlyJS.Plot(island_traces, layout))

# Display the plot
plot_figure
