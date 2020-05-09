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
        line = 4,
        title = title,
        legend = true,
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

""" function threecol_iterplot(data, repetition)
this plot is meant to be run to test a few repetitions of a model config

First column plots yvar= :r, :o, :sigma
Second and third columns are zooms of the first plot (:r)

"""
function threecol_iterplot(data, repetition)
    zoomplotdenominators = [10, 100, 10000]
    n = data[!, :id] |> unique |> length

    if !in("imgs", readdir("."))
        mkdir("./imgs")
        print("recursing here! I may be the source of any problem")
        threecol_iterplot(data, repetition)
    else
        p1 = timeplot(data, :r, "xr, $n agents, run $(repetition)")

        p2 = timeplot(data, :old_σ, "sigma, $n agents")

        p3 = timeplot(data, :old_o, "o, $n agents")

        r1c2, r2c2, r3c2 = (
            zoomplotdenominators .|>
                scaler -> zoomplot(data, :r, p1, zoomplotbounds, scaler, ", range/")
        )
        r1c3, r2c3, r3c3 = (
            zoomplotdenominators .|>
                scaler -> zoomplot(
                data,
                :r,
                p1,
                medianplotbounds,
                scaler,
                ", range = +- median * ",
            )
        )


        Plots.plot(
            p1,
            r1c2,
            r1c3,
            p2,
            r2c2,
            r2c3,
            p3,
            r3c2,
            r3c3,
            layout = (3, 3),
            dpi = 200,
            titlefont = Plots.font("sans-serif", pointsize = round(5.0)),
        )

        Plots.savefig("imgs/plot-n($n)-run($repetition).png")
    end
end
