;---Read file
fpath    = "/home/absen/WRF-Model/WRF/test/em_real/"
filename = "wrfout_d01_2022-01-01_00:00:00"
a        = addfile(fpath+filename,"r")

;---Get CEN_LAT and CEN_LON from WRF metadata (in global attributes)
cen_lat = a@CEN_LAT
cen_lon = a@CEN_LON

;---Select time index
nt = 30

;---Read temperature at first time step
tc = wrf_user_getvar(a, "tc", nt)

;---Open worksheet
wks = gsn_open_wks("png", "wrf_nogsn")

; Set up resource list that will be shared between the
; two wrf_contour calls.
res                      = True
res@gsnDraw              = False
res@gsnFrame             = False
res@tfDoNDCOverlay       = True

; Plotting options for air temperature
opts_r                      = res

opts_r@cnFillOn             = True
opts_r@cnLevelSelectionMode = "ExplicitLevels"
opts_r@cnLevels             = (/ 20, 22, 24, 26, 28, 30, 32 /)
opts_r@cnSmoothingOn        = True
opts_r@cnSmoothingDistanceF = .005

; Option for plt_res
plt_res = res

; Option for plt_res
map_res = res
map_res@mpDataBaseVersion           = "HighRes"
map_res@mpCenterLatF                = cen_lat
map_res@mpCenterLonF                = cen_lon
map_res@mpDataResolution            = "FinestResolution"
map_res@mpGeophysicalLineColor      = "black"
map_res@mpGeophysicalLineThicknessF = 2.0
map_res@mpGridSpacingF              = 1.0
map_res@mpGridLineColor             = "black"

; Plot
contour_tot = wrf_contour(a, wks, tc(0,:,:), opts_r)
plot = wrf_map_overlays(a, wks, (/contour_tot/), plt_res, map_res)