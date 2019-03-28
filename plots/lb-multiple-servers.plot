# Let's output to a jpeg file
set terminal jpeg size 1280,768
# This sets the aspect ratio of the graph
set size 1, 1
# The file we'll write to
set output "graphs/lb-multiple-servers.jpg"
# The graph title
set title "Load balancer with multiple backends: 10 concurrent connections"
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
set yrange [0:*]
# Tell gnuplot to use tabs as the delimiter instead of spaces (default)
set datafile separator '\t'
stats 'data/lb-1-apache-10.tsv' using 2 nooutput name 'X1_'
stats 'data/lb-2-apache-10.tsv' using 2 nooutput name 'X2_'
stats 'data/lb-10-apache-10.tsv' using 2 nooutput name 'X10_'
plot "data/lb-1-apache-10.tsv" using ($2- X1_min - 2):5 title "1 backend", \
     "data/lb-2-apache-10.tsv" using ($2- X2_min - 2):5 title "2 backends", \
     "data/lb-10-apache-10.tsv" using ($2- X10_min -2):5 title "10 backends"
exit
