"""
    function getys(p)
       Gets all the y values of a plot
"""
function getys(p)
    (p.series_list .|> (el -> el.plotattributes[:y]) |> (coll -> reduce(vcat, coll)))
end

"""
    function getplotminmax(p)
       gets min and max of plots' y
 """
function getplotminmax(p)
    ys = getys(p)
    min(ys...), max(ys...)
end

"""
    function getplotmedian(p)
        gets median of plot' y
"""
function getplotmedian(p)
    ys = getys(p)
    Stats.median(ys)
end

"""
    function medianplotbounds(n, p)
        Returns ± plot median * n
"""
function medianplotbounds(n, p)
    plotmedian = getplotmedian(p)
    # there seems to be a problem here, if the median is equal to 0? messes completely with this plot
    (-(n * plotmedian), n * plotmedian)
end

"""
    function zoomplotbounds(n, p)
        Returns plot (max,min) bounds / n
"""
function zoomplotbounds(n, p)
    plotminmax = getplotminmax(p)
    map(x -> x / n, plotminmax)
end


function timeplot(data, yvar, title)
    Plots.plot(
        data[!, :step],
        data[!, yvar],
        group = data[!, :id],
        alpha = 0.5,
        line = 1,
        title = title,
        legend = false,
    )
end

"this function bounds a plot "
function timeplot_diffyrange(data, yvar, title, ylims)
    p = timeplot(data, yvar, title)
    Plots.plot!(ylims = ylims)
    return (p)
end

"this function gets the title of a simple plot"
function getsimpleplottitle(p)
    p.subplots[1].attr[:title]
end


function zoomplot(data, var, p, bounds_extractor, scaler, titlemodifier)
    pover = bounds_extractor(scaler, p)
    povertitle = getsimpleplottitle(p) * titlemodifier * "$(scaler)"
    pl = timeplot_diffyrange(data, var, povertitle, pover)
    return pl
end
