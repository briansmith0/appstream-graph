# Copyright 2023 Brian Smith,  GPLv3 license:  https://www.gnu.org/licenses/gpl-3.0.en.html
# Specify the inputfile name and output file names with the -e option when calling gnuplot:
# gnuplot -e 'inputfile="rhel8_appstream.txt"' -e 'outputfile="rhel8_appstream.png"' appstream.gnu
# gnuplot -e 'inputfile="rhel9_appstream.txt"' -e 'outputfile="rhel9_appstream.png"' appstream.gnu

row_height=.2
color1=0xf8823c  # retired appstream
color2=0x0599c5  # less than 1 year until retirement
color3=0x83c199  # more than 1 year until retirement
color4=0xff0000  # current date line color

format_time = "%b %Y"                                                        
stats (inputfile) using (strptime(format_time,strcol(2))) nooutput

set timefmt "%b %Y"                                                        
set xdata  time    
set x2data time    
set xtics  center offset 8.5  #offset year labels so they are centered
set x2tics center offset 8.5  #offset year labels so they are centered
set format x "%Y"
set format x2 "%Y"
set title font ",25"
set xtics font ",15"
set x2tics font ",15"
set title "RHEL AppStream lifecycle, created:  ".strftime("%b %d %Y", time(0))
set yrange[0:STATS_records+1.25]
set terminal png size 2000,2000
set output (outputfile)
set arrow from (time(0)),0 to (time(0)),STATS_records+1.25 nohead lc rgb 'red' dt 2
set style fill solid
set grid
set key outside noautotitle center bottom
set bmargin 9 

timediff(t1,t2) = ((timecolumn(t2,format_time) - timecolumn(t1,format_time))/2)
starttime(s1,t1,t2) = timecolumn(s1) - ((timecolumn(t2,format_time) - timecolumn(t1,format_time))/2)
checkstatus(t1) = (timecolumn(t1,format_time) < (time(0))) ? color1 :  (  timecolumn(t1,format_time) < (time(0)+ (60*60*24*365)  ) ? color2 : color3 )

plot inputfile using (starttime(2,4,2)):($0+(1.25)):(timediff(4,2)):(row_height):(checkstatus(4)):ytic(1) with boxxy lc rgbcolor var, \
   keyentry with boxes linecolor rgb color1 title "Retired AppStream", \
   keyentry with boxes linecolor rgb color2 title "Less than 1 year until retirement", \
   keyentry with boxes linecolor rgb color3 title "More than 1 year until retirement", \
   keyentry with lines linecolor rgb color4 linewidth 2 title "Date graph created (".strftime("%b %d %Y", time(0)).")", 
