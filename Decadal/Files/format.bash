#!/bin/bash

#json_file to be contructed from: https://esgf-data.dkrz.de/esg-search/search/?offset=0&limit=10000&type=Dataset&replica=false&latest=true&source_id=EC-Earth3i%2CMPI-ESM1-2-HR%2CCMCC-CM2-SR5%2CHadGEM3-GC31-MM&experiment_id=dcppA-hindcast%2CdcppB-forecast&frequency=mon&variable_id=pr%2Cpsl%2Ctas%2Ctasmax%2Ctasmin%2Czg&mip_era=CMIP6&activity_id!=input4MIPs&facets=mip_era%2Cactivity_id%2Cmodel_cohort%2Cproduct%2Csource_id%2Cinstitution_id%2Csource_type%2Cnominal_resolution%2Cexperiment_id%2Csub_experiment_id%2Cvariant_label%2Cgrid_label%2Ctable_id%2Cfrequency%2Crealm%2Cvariable_id%2Ccf_standard_name%2Cdata_node&format=application%2Fsolr%2Bjson


f=tas_Amon_EC-Earth3_dcppA-hindcast_s1986-r1i1p1f1_gr_198711-198810.nc
start_date=$(echo $f | cut -f5 -d"_" | cut -f2- | cut -f1 -d"-") #s1986
extendend_start_date=${start_date}11 #s198611 all experiments starting in November
new_file=$(echo $f | sed "s/s$start_date/s$extended_start_date/g")
realization=$(echo $f | cut -f5 -d"_" | cut -f2 -d"-" | cut c2- | cut -f1 -d"_")
model=$(echo $f | cut -f3 -d"_")
case $model in 
 "EC-Earth3") initialization_description=initialization_description ; physics_description=physics_description ; forcing_description=forcing_description;;
 "HadGEM3-GC31-MM") initialization_description=initialization_description ; physics_description=physics_description ; forcing_description=forcing_description;;
 "CMCC-CM2-SR5") initialization_description=initialization_description ; physics_description=physics_description ; forcing_description=forcing_description;;
 "MPI-ESM1-2-HR") initialization_description=initialization_description ; physics_description=physics_description ; forcing_description=forcing_description;;
esac

reftime=$( echo $(( ($(date --date=${extended_start_date}01 '+%s' ) - $( date --date=18500101 '+%s') )/(3600*24) )) )
ncap2 -O -s reftime=$reftime $new_file $new_file
ncatted -O -a long_name,reftime,c,c,"Start date of the forecast" $new_file
ncatted -O -a standard_name_name,reftime,c,c,"forecast_reference_time" $new_file
ncatted -O -a units,reftime,c,c,"days since 1850-01-01" $new_file
ncatted -O -a calendar,reftime,c,c,"gregorian" $new_file


ncap2 -O -s leadtime=array(15,30,$time) $new_file
ncatted -O -a long_name,leadtime,c,c,"Time elapsed since the start of the forecast" $new_file
ncatted -O -a standard_name,leadtime,c,c,"forecast_period" $new_file
ncatted -O -a units,leadtime,c,c,"days" $new_file

ncatted -O -a long_name,time,m,c,valid_time $new_file

ncap2 -O -s realization=$realization $new_file
ncatted -O -a comment,realization,c,c,"For more information on the ripf, refer to the variant_label, initialization_description, physics_description and forcing_description global attributes" $new_file
ncatted -O -a long_name,realization,c,c,realization $new_file

ncatted -O -a coordinates,tas,m,c,"height reftime leadtime" $new_file
ncatted -O -a forcing_description,global,c,c,$forcing $new_file
ncatted -O -a physics_description,global,c,c,$physics $new_file
ncatted -O -a initialization_description,global,c,c,$initialization_description $new_file
ncatted -O -a sub_experiment_id,global,m,c,s$extendend_start_date_description $new_file
ncatted -O -a startdate,global,m,c,s$extendend_start_date_description $new_file
