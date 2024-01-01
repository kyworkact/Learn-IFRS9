using CSV
using DataFrames
using HTTP

function load_data()
    # url = "https://raw.githubusercontent.com/naenumtou/ifrs9/main/PD/datasets/PDCurves.csv"
    # response = HTTP.get(url)
    # open("PDCurves.csv", "w") do file
    #     write(file, String(response.body))
    # end
    # return DataFrame(CSV.File("PDCurves.csv", normalizenames=true))
    return DataFrame(CSV.File("C://Gproject//IFRS9//PD//datasets//PDCurves.csv", normalizenames=true))
end

function calculate_factors(df)
    factors = Float64[]

    for segment in unique(df.Segment)
        for aging in unique(df.Aging)
            data = filter(row -> row.Segment == segment && row.Aging == aging, df)
            data = select!(data, Not([:Segment, :Aging, :Year]))

            for i in 1:size(data, 2) - 2
                forward = data[:, i+2]

                if any(ismissing.(forward))
                    a = count(.!(ismissing.(forward)))
                    current = data[1:a, i+1]
                    forward = data[1:a, i+2]
                    factor = sum(forward .* data[1:a, 1]) / sum(current .* data[1:a, 1])
                    push!(factors, factor)
                end
            end
        end
    end

    return DataFrame(reshape(factors, :, (length(unique(df.Segment)) * length(unique(df.Aging))))', :auto)
end

function project_pd(df, factors)
    df_chain = DataFrame()

    for (s, segment) in enumerate(unique(df.Segment))
        for (a, aging) in enumerate(unique(df.Aging))
            data = filter(row -> row.Segment == segment && row.Aging == aging, df)
            factor = factors[(s-1)*size(unique(df.Aging),1)+a, :]

            for i in 1:size(data, 2) - 4
                for j in 1:size(data, 1)
                    if ismissing(data[j, i+4])
                        data[j, i+4] = data[j, i-1+4] * factor[i-12]
                    end
                end
            end

            append!(df_chain, data)
        end
    end

    return df_chain
end
