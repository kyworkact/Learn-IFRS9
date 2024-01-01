using DataFrames

function weighted_average(data)
    average_result = DataFrame()

    for col in names(data[:, 5:end])
        select_data = dropmissing!(data[:, [:Segment, :Aging, :N, Symbol(col)]], Symbol(col))
        average = combine(groupby(select_data, [:Segment, :Aging]), [Symbol(col), :N] => ((c, n) -> sum(c .* n) / sum(n)) => :waRate)
        average[!, :colname] = fill(Symbol(col), nrow(average))
        average_result = vcat(average_result, average)
    end

    average_result = unstack(average_result, [:Segment, :Aging], :colname, :waRate)
    return average_result
end
