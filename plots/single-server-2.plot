# Let's output to a jpeg file
#set terminal jpeg size 1280,768
set terminal jpeg size 640,480
# This sets the aspect ratio of the graph
set size 1, 1
# The file we'll write to
set output "graphs/single-server-2.jpg"
# The graph title
set title "Single server accepting 2 simultanous clients"
# Where to place the legend/key
set key left top
# Draw gridlines oriented on the y axis
set grid y
# Specify that the x-series data is time data
#set xdata time
# Specify the *input* format of the time data
#set timefmt "%s"
# Specify the *output* format for the x-axis tick labels
# Label the x-axis
set xlabel 'Seconds to get a response'
# Label the y-axis
set ylabel "% of completed requests"
set grid x
#set logscale x
set xrange [1:*]
set grid y
set format y '%2.0f%%'

set key cent right
# Tell gnuplot to use tabs as the delimiter instead of spaces (default)
set datafile separator '\t'
stats 'data/plot-apache-10.tsv' every ::2 using 5 nooutput name 'X10_'
stats 'data/plot-apache-3.tsv' every ::2 using 5 nooutput name 'X3_'
stats 'data/plot-apache-2.tsv' every ::2 using 5 nooutput name 'X2_'
# Plot the data
plot "<(tail -n +2 data/plot-apache-10.tsv | sort -n -k 9)" every ::2 using ($5/1000):(100*$0/X10_records) smooth sbezier with lines t '10 concurrent connections' lw 2, \
     "<(tail -n +2 data/plot-apache-3.tsv | sort -n -k 9)" every ::2 using ($5/1000):(100*$0/X10_records) smooth sbezier with lines t '3 concurrent connections' lw 2, \
     "<(tail -n +2 data/plot-apache-2.tsv | sort -n -k 9)" every ::2 using ($5/1000):(100*$0/X10_records) smooth sbezier with lines t '2 concurrent connections' lw 2
exit
