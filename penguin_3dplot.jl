using CSV, DataFrames, PalmerPenguins, Statistics, PooledArrays, PlotlyJS, Python

# Import Python libraries using Python.jl
@pyimport numpy as np

# Step 1: Load the Palmer Penguins dataset and drop missing values
penguins = dropmissing(DataFrame(PalmerPenguins.load()))

# Step 2: Convert necessary columns to Float64 for numerical computations
numeric_cols = [:flipper_length_mm, :bill_length_mm, :body_mass_g]
for col in numeric_cols
    penguins[!, col] = convert(Vector{Float64}, penguins[!, col])
end

# Step 3: Convert categorical columns to string for processing
categorical_cols = [:species, :island, :sex]
for col in categorical_cols
    penguins[!, col] = convert(Vector{String}, penguins[!, col])
end

# Step 4: Encode species labels to numerical indices (0, 1, 2)
species_to_index = Dict("Adelie" => 0, "Gentoo" => 1, "Chinstrap" => 2)
index_to_species = Dict(0 => "Adelie", 1 => "Gentoo", 2 => "Chinstrap")  # Inverse mapping for easy lookup
penguins[!, :species_index] = [species_to_index[species] for species in penguins.species]

# Step 5: Calculate means and standard deviations for each species for each feature
species_means = combine(groupby(penguins, :species), 
    :flipper_length_mm => mean => :flipper_length_mean, 
    :bill_length_mm => mean => :bill_length_mean, 
    :body_mass_g => mean => :body_mass_mean)

species_stds = combine(groupby(penguins, :species), 
    :flipper_length_mm => std => :flipper_length_std, 
    :bill_length_mm => std => :bill_length_std, 
    :body_mass_g => std => :body_mass_std)

# Step 6: Create a matrix of z-scores for each penguin for each species
function compute_z_scores(penguin, species_means, species_stds)
    z_scores = zeros(3, 3)  # 3 species x 3 features
    for (species, index) in species_to_index
        mean_vals = [
            species_means[species_means.species .== species, :flipper_length_mean][1],
            species_means[species_means.species .== species, :bill_length_mean][1],
            species_means[species_means.species .== species, :body_mass_mean][1]
        ]

        std_vals = [
            species_stds[species_stds.species .== species, :flipper_length_std][1],
            species_stds[species_stds.species .== species, :bill_length_std][1],
            species_stds[species_stds.species .== species, :body_mass_std][1]
        ]

        for i in 1:3  # Loop over features
            z_scores[index + 1, i] = (penguin[i] - mean_vals[i]) / std_vals[i]
        end
    end
    return z_scores
end

# Step 7: Calculate a probability-like measure using z-scores for each penguin
function compute_species_probabilities(z_scores)
    probabilities = exp.(-abs.(z_scores))  # Gaussian-like probabilities for each z-score
    species_probabilities = sum(probabilities, dims=2)  # Sum over features
    species_probabilities /= sum(species_probabilities)  # Normalize distribution
    return vec(species_probabilities)  # Return as 1x3 vector
end

# Custom function to convert probability to RGB color (R,G,B values between 0 and 255)
function probability_to_color(probabilities)
    red = 255 * probabilities[1]     # Red for Adelie
    green = 255 * probabilities[2]   # Green for Gentoo
    blue = 255 * probabilities[3]    # Blue for Chinstrap
    return "rgb($(round(red)), $(round(green)), $(round(blue)))"
end

# Step 8: Create traces for each penguin using the computed probability cloud
penguin_traces = PlotlyJS.GenericTrace[]

# Create separate traces for each combination of island and sex
for (island, sex) in Iterators.product(unique(penguins.island), unique(penguins.sex))
    # Filter penguins based on current island and sex
    filtered_penguins = penguins[(penguins.island .== island) .& (penguins.sex .== sex), :]

    # Initialize arrays for storing individual penguin data
    x_vals, y_vals, z_vals, colors, hover_texts = [], [], [], [], []

    for i in 1:nrow(filtered_penguins)
        penguin_features = [filtered_penguins.flipper_length_mm[i], filtered_penguins.bill_length_mm[i], filtered_penguins.body_mass_g[i]]

        # Compute z-scores relative to each species
        z_scores = compute_z_scores(penguin_features, species_means, species_stds)

        # Compute species probabilities based on z-scores
        probabilities = compute_species_probabilities(z_scores)

        # Determine the color based on the probability distribution
        color = probability_to_color(probabilities)

        # Store coordinates and color
        push!(x_vals, filtered_penguins.flipper_length_mm[i])
        push!(y_vals, filtered_penguins.bill_length_mm[i])
        push!(z_vals, filtered_penguins.body_mass_g[i])
        push!(colors, color)

        # Corrected: Use `index_to_species` to get the species name from the index
        species_name = index_to_species[argmax(probabilities) - 1]  # -1 because `argmax` returns 1-based index
        # Create custom hover text for each individual penguin point
        hover_text = "Species: $species_name<br>Flipper Length (mm): $(filtered_penguins.flipper_length_mm[i]) mm<br>Bill Length (mm): $(filtered_penguins.bill_length_mm[i]) mm<br>Body Mass (g): $(filtered_penguins.body_mass_g[i]) g<br>Adelie Prob: $(round(probabilities[1], digits=2))<br>Gentoo Prob: $(round(probabilities[2], digits=2))<br>Chinstrap Prob: $(round(probabilities[3], digits=2))"
        push!(hover_texts, hover_text)
    end

    # Create a 3D scatter trace for the filtered group
    trace = PlotlyJS.scatter3d(
        x = x_vals,
        y = y_vals,
        z = z_vals,
        mode = "markers",
        marker = Dict(
            :size => 6,
            :color => colors,  # Color based on probability distribution
            :opacity => 0.7  # Set constant opacity for visualization
        ),
        name = "$island | $sex",  # Set the name for each trace
        text = hover_texts,  # Custom hover text for individual statistics
        hoverinfo = "text"  # Display only custom hover text based on cursor
    )
    push!(penguin_traces, trace)
end

# Step 9: Define layout for 3D plot with mm and g units in axis labels
layout = PlotlyJS.Layout(
    title = "Interactive 3D Scatter Plot of Penguins by Island and Sex",
    scene = attr(
        xaxis = attr(title = "Flipper Length (mm)", showgrid = true, zeroline = false),
        yaxis = attr(title = "Bill Length (mm)", showgrid = true, zeroline = false),
        zaxis = attr(title = "Body Mass (g)", showgrid = true, zeroline = false)
    ),
    legend = attr(
        title = attr(text = "Island and Sex"),
        x = 0.85,
        y = 1,
        bgcolor = "rgba(255, 255, 255, 0.5)"  # Semi-transparent white background
    ),
    updatemenus = [  # Create interactive buttons for island and sex filters
        attr(
            buttons = [
                attr(args = ["visible", [true for _ in 1:length(penguin_traces)]], label = "Show All", method = "restyle"),
                attr(args = ["visible", [trace.name[1:9] == "Torgersen" for trace in penguin_traces]], label = "Torgersen", method = "restyle"),
                attr(args = ["visible", [trace.name[1:5] == "Biscoe" for trace in penguin_traces]], label = "Biscoe", method = "restyle"),
                attr(args = ["visible", [trace.name[1:5] == "Dream" for trace in penguin_traces]], label = "Dream", method = "restyle"),
                attr(args = ["visible", [trace.name[end-3:end] == "Male" for trace in penguin_traces]], label = "Male", method = "restyle"),
                attr(args = ["visible", [trace.name[end-6:end] == "Female" for trace in penguin_traces]], label = "Female", method = "restyle")
            ],
            direction = "down",
            showactive = true,
            x = 1.15, 
            xanchor = "left",
            y = 0.9,
            yanchor = "top",
            title = "Filters"
        )
    ]
)

# Step 10: Combine scatter plot traces and layout using PlotlyJS.plot
plot_figure = PlotlyJS.plot(vcat(penguin_traces), layout)

# Display the plot
plot_figure
