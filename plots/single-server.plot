# Let's output to a jpeg file
#set terminal jpeg size 1280,768
set terminal jpeg size 640,480
# This sets the aspect ratio of the graph
set size 1, 1
# The file we'll write to
set output "graphs/single-server.jpg"
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
set xlabel 'Seconds elapsed for requests'
# Label the y-axis
set ylabel "Response time (ms)"
set yrange [1500:*]
set xrange [-15:615]
set key cent right
# Tell gnuplot to use tabs as the delimiter instead of spaces (default)
set datafile separator '\t'
stats 'data/plot-apache-10.tsv' every ::2 using 2 nooutput name 'X10_'
stats 'data/plot-apache-3.tsv' every ::2 using 2 nooutput name 'X3_'
stats 'data/plot-apache-2.tsv' every ::2 using 2 nooutput name 'X2_'
# Plot the data
plot "data/plot-apache-10.tsv" every ::2 using ($2-X10_min-2):5 title '10 concurrent connections' with points pt 7 ps 1.5, \
     "data/plot-apache-3.tsv" every ::2 using ($2-X3_min-2):5 title '3 concurrent connections' with points pt 7 ps 1.5, \
     "data/plot-apache-2.tsv" every ::2 using ($2-X2_min-2):5 title '2 concurrent connections' with points pt 7 ps 1.5
exit
