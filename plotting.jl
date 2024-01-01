using Statistics, DataFrames

function plot_pd(df_chain)
    stacked_df = stack(df_chain, Not([:Segment, :Aging, :Year, :N]))
    rename!(stacked_df, :variable => :times, :value => :badRate)
    stacked_df[!, :times] = parse.(Int, replace.(stacked_df[!, :times], "_" => ""))
    group_data = combine(groupby(stacked_df, [:Segment, :Year, :times]), :badRate => mean => :badRate)
    return group_data
end

function plot_weighted_average_pd(data)
    stacked_df = stack(data, Not([:Segment, :Aging]))
    rename!(stacked_df, :variable => :times, :value => :badRate)
    stacked_df[!, :times] = parse.(Int, replace.(stacked_df[!, :times], "_" => ""))
    group_data = stacked_df
    return group_data
end
