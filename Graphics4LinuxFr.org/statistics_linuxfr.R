# Copyright 2017, 1gfypobb6sznxm9@jetable.org
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

### Add-ons tools used, all availaible at https://cran.r-project.org/

neededPackages <- c("ggplot2", "ggfortify", "ggthemes")
status <- sapply(neededPackages, require, character.only = TRUE)

if (!all(status)) {
    installed.packages(neededPackages[!status])
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

### Loading data
################

# As of today, the source file for statistics is located at
# <https://linuxfr.org/webalizer/data.csv>. Therein, dates formatting does not
# comply to any standard (IETF and ISO). Thus, no current tool in R can
# automatically parse them without error. This function adds the missing parts
# in the date formatting, namely the days, so that there comply to known
# formatting schemes.
#
# Parameters
#
# x: a one-length character vector containing the dates to format
correctDates <- function(x) {
    value <- x

    fullDate <-
        list(
            month = c(paste0("/0", seq_len(9L)), "/10", "/11", "/12"),
            day = c(
                "31",
                "28",
                "31",
                "30",
                "31",
                "30",
                "31",
                "31",
                "30",
                "31",
                "30",
                "31"
            ),
            monthAndDay = character(12L)
        )

    fullDate$monthAndDay <-
        paste(fullDate$month, fullDate$day, sep = "/")

    for (i in seq_len(12L)) {
        value <- gsub(paste0("(", fullDate$month[i], ")$"),
                      fullDate$monthAndDay[i],
                      value,
                      perl = TRUE)
    }

    bissextile <- seq(from = 2004L,
                      by = 4L,
                      length.out = ceiling((as.integer(
                          format(Sys.time(), "%Y")
                      ) - 2004L) / 4L))

    leap <- paste0(bissextile, "/02/29")
    j <- 1L
    for (i in paste0(bissextile, "/02/28")) {
        value <- gsub(paste0("(", i, ")$"), leap[j], value, perl = TRUE)
        j <- j + 1L
    }

    as.Date(value)
}



# Read in the LinuxFr.org statistics file
#
# Parameters
#
# fileName: the path to the tab-delimitted file to read in
neatData <- function(fileName = "data.csv") {
    rawData <- read.table(
        fileName,
        header = TRUE,
        sep = "\t",
        numerals = "warn.loss",
        colClasses = c("character", rep("numeric", 8L))
    )

    colnames(rawData) <-
        unlist(strsplit(readLines(fileName, n = 1L), "\t"))

    rawData$Month <- correctDates(rawData$Month)
    rawData
}


# From all the statistics, pick those covering a particular year period of time.
#
# Parameters
#
# fullData: a data.frame of all the statistics of which to take a slice
# year: an integer indicating which year to consider
extractAnnualData <-
    function(fullData,
             year = 2016L,
             monthColumn = "Month") {
        fullData[grepl(paste0("^", as.character(year)),
                       fullData[[monthColumn]],
                       perl = TRUE)
                 ,]
    }


bulkData <- neatData()
graphPars <-
    list(widthInch = 12,
         heightInch = 12,
         graphDir = "./our_images")

allTimeSeries <- ts(
    bulkData[, -1L],
    start = c(2002L, 10L),
    end = c(2016L, 12L),
    deltat = 1 / 12
)

subset2016TimeSeries <- ts(
    extractAnnualData(bulkData)[, -1L],
    start = c(2016L, 1L),
    end = c(2016L, 12L),
    deltat = 1 / 12
)

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

### Base plots
##############

if (!dir.exists(graphPars$graphDir)) {
    dir.create(graphPars$graphDir, mode = "740")
}


destBaseStats <- normalizePath(paste0(graphPars$graphDir, "/base_stats"))
if (!dir.exists(destBaseStats)) {
    dir.create(destBaseStats)
}

tmpCwd <- setwd(destBaseStats)


svg(
    "base_graphics-all_data.svg",
    family = "serif",
    width = graphPars$widthInch * 2,
    height = graphPars$heightInch
)

plot.ts(allTimeSeries,
        xy.labels = TRUE,
        nc = 4L,
        main = "")

graphics.off()


svg(
    "base_graphics-2016_data.svg",
    family = "serif",
    width = graphPars$widthInch,
    height = graphPars$heightInch
)

plot.ts(
    subset2016TimeSeries,
    xy.labels = TRUE,
    nc = 1L,
    main = ""
)

graphics.off()

setwd(tmpCwd)

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

### Lattice plots

# A wrapper around ggplot2::ggsave. See the latter function for further details.
# Three preset themes are applied to each plot object passed to the wrapper.
utilSaveLatticePlot <-
    function(graphicVar,
             imgBasename,
             imgWidth = 12,
             imgHeight = 12,
             imgDPI = 360L,
             small = FALSE) {
        ggsave(
            plot = graphicVar + theme_fivethirtyeight() +
                theme(legend.title = element_blank()),
            filename = paste0(imgBasename, "-538.svg"),
            dpi = imgDPI,
            width = imgWidth,
            height = imgHeight,
            limitsize = small
        )

        ggsave(
            plot = graphicVar + theme_tufte() +
                theme(legend.title = element_blank()),
            filename = paste0(imgBasename, "-tufte.svg"),
            dpi = imgDPI,
            width = imgWidth,
            height = imgHeight,
            limitsize = small
        )

        ggsave(
            plot = graphicVar + theme_wsj() +
                theme(legend.title = element_blank()),
            filename = paste0(imgBasename, "-wsj.svg"),
            dpi = imgDPI,
            width = imgWidth,
            height = imgHeight,
            limitsize = small
        )

        invisible(TRUE)
    }


# Write the statistics plots on the filesystem.
#
# Parameter
#
# x: the time series object holding statistics to render and save
#
# plotBaseNames: base names to the generated plots
utilPlotStats <- function(x, plotBaseNames) {
    ctn <- list(
        autoplot(x,
                 ts.geom = 'line',
                 facets = TRUE),
        #
        autoplot(x,
                 ts.geom = 'line',
                 facets = FALSE) +
            scale_y_log10(),
        #
        autoplot(x,
                 ts.geom = 'bar',
                 facets = TRUE),
        #
        autoplot(x,
                 ts.geom = 'bar',
                 facets = FALSE) +
            scale_y_log10(),
        #
        autoplot(
            x,
            ts.geom = 'bar',
            facets = FALSE,
            stacked = TRUE
        ) + scale_y_log10(),
        #
        autoplot(x,
                 ts.geom = 'ribbon',
                 facets = FALSE) +
            scale_y_log10(),
        #
        autoplot(
            x,
            ts.geom = 'ribbon',
            facets = FALSE,
            stacked = TRUE
        ) + scale_y_log10(),
        #
        autoplot(x,
                 ts.geom = 'point',
                 facets = FALSE) +
            scale_y_log10()
    )

    names(ctn) <- plotBaseNames

    for (i in plotBaseNames) {
        utilSaveLatticePlot(ctn[[i]], i)
    }

    invisible(ctn)
}


destAnnualStats <-
    normalizePath(paste0(graphPars$graphDir, "/annual_stats"))
if (!dir.exists(destAnnualStats)) {
    dir.create(destAnnualStats)
}

tmpCwd <- setwd(destAnnualStats)

year <- 2016L
utilPlotStats(
    subset2016TimeSeries,
    c(
        paste0("line", year, "WithFacets"),
        paste0("line", year, "FacetLess"),
        paste0("bar", year, "WithFacets"),
        paste0("bar", year, "FacetLess"),
        paste0("bar", year, "StackedFacetLess"),
        paste0("ribbon", year, "FacetLess"),
        paste0("ribbon", year, "StackedFacetLess"),
        paste0("point", year, "FacetLess")
    )
)

setwd(tmpCwd)



destAllStats <-
    normalizePath(paste0(graphPars$graphDir, "/all_stats"))
if (!dir.exists(destAllStats)) {
    dir.create(destAllStats)
}

tmpCwd <- setwd(destAllStats)


utilPlotStats(
    allTimeSeries,
    c(
        "lineWithFacets",
        "lineFacetLess",
        "barWithFacets",
        "barFacetLess",
        "barStackedFacetLess",
        "ribbonFacetLess",
        "ribbonStackedFacetLess",
        "pointFacetLess"
    )
)

setwd(tmpCwd)

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
