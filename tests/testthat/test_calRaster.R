context("calRaster")
library(assignR)
library(raster)
data("naMap")
data("d2h_world")
d = subOrigData(group = "Modern human")
d_hasNA = d
d_hasNA$data$d2H[1] = NA
d_diffProj = d
d_diffProj$data = spTransform(d$data, "+init=epsg:28992")
d_usr_bad = d$data
d_usr_good = d_usr_bad
d_usr_good@data = data.frame(d$data$d2H, d$data$d2H.sd)
d_noCRS=d
crs(d_noCRS$data) = NA

d2h_world_noCRS = d2h_world
crs(d2h_world_noCRS) = NA

mask_diffProj = spTransform(naMap, "+init=epsg:28992")

mask_noCRS = naMap
crs(mask_noCRS) = NA

tempVals = getValues(d2h_world)
tempVals[is.nan(tempVals)] = 9999
d2h_world_with9999 = setValues(d2h_world, tempVals)

d2h_world_na = crop(d2h_world, naMap)

r1 = calRaster(known = d, isoscape = d2h_world, mask = naMap)
r2 = calRaster(known = d, isoscape = d2h_world, mask = naMap, interpMethod = 1)
r3 = calRaster(known = d, isoscape = d2h_world_with9999, NA.value = 9999)

test_that("calRaster can correctly uses known-origin tissue data to rescale a map of 
          environmental isotope values to a map of tissue value (and associated uncertainty) 
          using a linear regression model.",{
        expect_is(r1, "rescale")
        expect_is(r2, "rescale")
        expect_is(r3, "rescale")
        expect_is(calRaster(known = d_usr_good, isoscape = d2h_world), "rescale")
        expect_output(calRaster(known = d, isoscape = d2h_world, outDir = "temp"))
        expect_equal(nlayers(r1$isoscape.rescale), 2)
        expect_error(calRaster(known = d$data$d2H, isoscape = d2h_world))
        expect_error(calRaster(known = d, isoscape = d2h_world, outDir = 2))
        expect_error(calRaster(known = d, isoscape = d2h_world, interpMethod = 3))
        expect_error(calRaster(known = d, isoscape = d2h_world, genplot = 2))
        expect_error(calRaster(known = d, isoscape = d2h_world_noCRS))
        expect_error(calRaster(known = d, isoscape = d2h_world$mean))
        expect_error(calRaster(known = d_usr_bad, isoscape = d2h_world))
        expect_error(calRaster(known = d, isoscape = d2h_world, mask = mask_noCRS))
        expect_error(calRaster(known = d, isoscape = d2h_world, mask = d))
        expect_error(calRaster(known = d_noCRS, isoscape = d2h_world))
        expect_error(calRaster(known = d_hasNA, isoscape = d2h_world, ignore.NA = F))
        expect_error(calRaster(known = d, isoscape = d2h_world_na, ignore.NA = FALSE))
        expect_warning(calRaster(known = d_diffProj, isoscape = d2h_world))
        expect_warning(calRaster(known = d, isoscape = d2h_world, mask = mask_diffProj))
        expect_warning(calRaster(known = d, isoscape = d2h_world_na))
})
