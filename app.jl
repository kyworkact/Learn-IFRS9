using Dash
using DataFrames, CSV, PlotlyJS

include("data_processing.jl")
include("plotting.jl")
include("utils.jl")

# Load data, calculate factors, and project PD
df = load_data()
factors = calculate_factors(df)
df_chain = project_pd(df, factors)
df_chain_plot = plot_pd(df_chain)

df_avg_data = plot_weighted_average_pd(weighted_average(df))
df_avg_chain = plot_weighted_average_pd(weighted_average(df_chain))
available_segment = unique(df[!, "Segment"])
available_data_type = ["Raw", "Projected"]
dataDict = Dict("Raw" => df_avg_data, "Projected" => df_avg_chain)

app = dash()

app.layout = html_div() do
    html_div(
        children = [
            dcc_dropdown(
                id = "segment-selection",
                options = [
                    (label = i, value = i) for i in available_segment
                ],
                value = "CU",
            ),
        ],
    ),
    dcc_graph(id = "pd-graphic"),
    html_div(
        children = [
            dcc_dropdown(
                id = "data-type-selection",
                options = [
                    (label = i, value = i) for i in available_data_type
                ],
                value = "Raw",
            ),
        ],
    ),
    dcc_graph(id = "avg-pd-graphic")
end

callback!(
    app,
    Output("pd-graphic", "figure"),
    Output("avg-pd-graphic", "figure"),
    Input("segment-selection", "value"),
    Input("data-type-selection", "value"),
) do segmentselection, dataType
    dff = filter(row -> row.Segment == segmentselection, df_chain_plot)
    plot1 = Plot(
        dff,
        x = :times,
        y = :badRate,
        group = :Year,
        Layout(
            xaxis_title = segmentselection
        )
    )
    dff2 = filter(row -> row.Segment == segmentselection, dataDict[dataType])
    plot2 = Plot(
        dff2,
        x = :times,
        y = :badRate,
        group = :Aging,
        Layout(
            xaxis_title = segmentselection
        )
    )
    return plot1, plot2
end

run_server(app, "0.0.0.0", debug=true)