options(stringsAsFactors = FALSE)
library(openxlsx)
library(sp)
library(devtools)

#WGS84 projection
p = CRS("+proj=longlat +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +no_defs")

#World outline map
load("data-raw/wrld_simpl.rda")
proj4string(wrld_simpl) = p

#This one is internal
use_data(wrld_simpl, internal = TRUE, overwrite = TRUE)

#adjacency matrix for H
ham = read.xlsx("data-raw/ham.xlsx", rowNames = TRUE)
ham = as.matrix(ham)
#Verify matrix symmetry
isSymmetric(ham)

#adjacency matrix for O
oam = read.xlsx("data-raw/oam.xlsx", rowNames = TRUE)
oam = as.matrix(oam)
#Verify matrix xymmetry
isSymmetric(oam)

#Standards definitions files
hrms = read.xlsx("data-raw/hrms.xlsx")
orms = read.xlsx("data-raw/orms.xlsx")

#Verify rownumber matches adjacency matrix dimensions
nrow(hrms) == nrow(ham)
nrow(orms) == nrow(oam)

#Verify that all matrix entries have a match in definition file
all(row.names(ham) %in% hrms$Calibration)
all(row.names(oam) %in% orms$Calibration)

#Known origin data table
knownOrig_sources = read.xlsx("data-raw/knownOrigNew.xlsx", 
                              sheet = "knownOrig_sources")
sites = read.xlsx("data-raw/knownOrigNew.xlsx", 
                              sheet = "knownOrig_sites")
knownOrig_samples = read.xlsx("data-raw/knownOrigNew.xlsx", 
                              sheet = "knownOrig_samples")

#check standard scale names
ss = unique(knownOrig_sources$H_cal)
ss = ss[!is.na(ss)]
all(ss %in% hrms$Calibration)
ss = unique(knownOrig_sources$O_cal)
ss = ss[!is.na(ss)]
all(ss %in% orms$Calibration)

#check linking fields
all(knownOrig_samples$Site_ID %in% sites$Site_ID)
all(knownOrig_samples$Dataset_ID %in% knownOrig_sources$Dataset_ID)

#Convert to SPDF
knownOrig_sites = SpatialPointsDataFrame(sites[,2:3], 
                                         data = sites[,c(1,4:ncol(sites))],
                                         proj4string = p)

#Group data objects
knownOrig = list(sites = knownOrig_sites, samples = knownOrig_samples, 
                 sources = knownOrig_sources)

refMats = list(hrms = hrms, orms = orms, ham = ham, oam = oam)
  
#Write it all to /data/
use_data(knownOrig, refMats, overwrite = TRUE)
