# pres=( 1000.0 850.0 500.0 )
# varID=20049
# levelType="Pressure"
# varname="vwnd"

# for pres in "${pres[@]}"
# do
#     wget "https://psl.noaa.gov/cgi-bin/mddb2/plot.pl?doplot=0&varID=${varID}&fileID=0&itype=0&variable=${varname}&levelType=${levelType}%20Levels&level_units=millibar&level=${pres}&timetype=mon&fileTimetype=mon&createAverage=1&year1=2000&month1=1&day1=1&hr1=00%20Z&year2=2022&month2=12&day2=1&hr2=00%20Z&region=Custom&area_north=15&area_west=80&area_east=160&area_south=-15&centerLat=0.0&centerLon=270.0" -O ${varname}.${pres}mb.mon.mean.2000-2022.nc
# done

varID=( 20019 20013 20009 20036 20021 20032 20025 20005 20012 20030 )
levelType="Surface"
varname=( "cprat" "gflux" "lhtfl" "uflx" "vflx" "pevpr" "prate" "pres" "shtfl" "skt" )
lenvar=${#varID[@]}

for (( i=0; i<$lenvar; i++))
do
    wget "https://psl.noaa.gov/cgi-bin/mddb2/plot.pl?doplot=0&varID=${varID[$i]}&fileID=0&itype=0&variable=${varname[$i]}&levelType=${levelType}&level_units=&level=${levelType}&timetype=mon&fileTimetype=mon&createAverage=1&year1=2000&month1=1&day1=1&hr1=00%20Z&year2=2022&month2=12&day2=1&hr2=00%20Z&region=Custom&area_north=15&area_west=80&area_east=160&area_south=-15&centerLat=0.0&centerLon=270.0" -O ${varname[$i]}.sfc.mon.mean.2000-2022.nc -nc
done

# varID=( 20017 20041 20033 20018 )
# varID=( 20080 20016 )
# varID=( 20079 )
# levelType="Sea%20Level"
# varname=( "mslp" )
# lenvar=${#varID[@]}
# 
# for (( i=0; i<$lenvar; i++)) 
# do
#     wget "https://psl.noaa.gov/cgi-bin/mddb2/plot.pl?doplot=0&varID=${varID[$i]}&fileID=0&itype=0&variable=${varname[$i]}&levelType=${levelType}&level_units=&level=${levelType}&timetype=mon&fileTimetype=mon&createAverage=1&year1=2000&month1=1&day1=1&hr1=00%20Z&year2=2022&month2=12&day2=1&hr2=00%20Z&region=Custom&area_north=15&area_west=80&area_east=160&area_south=-15&centerLat=0.0&centerLon=270.0" -O ${varname[$i]}.tcol.mon.mean.2000-2022.nc -nc
# done