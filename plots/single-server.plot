# Let's output to a jpeg file
set terminal jpeg size 1280,768
# This sets the aspect ratio of the graph
set size 1, 1
# The file we'll write to
set output "graphs/single-server.jpg"
# The graph title
set title "Single server"
# Where to place the legend/key
set key left top
# Draw gridlines oriented on the y axis
set grid y
# Specify that the x-series data is time data
#set xdata time
# Specify the *input* format of the time data
#set timefmt "%s"
# Specify the *output* format for the x-axis tick labels
#set format x "%S"
# Label the x-axis
set xlabel 'requests'
# Label the y-axis
set ylabel "response time (ms)"
# Tell gnuplot to use tabs as the delimiter instead of spaces (default)
set datafile separator '\t'
# Plot the data
#plot "plot-apache-60.tsv" using 2:5 title 'response time' with points
plot "data/plot-apache-10.tsv" using 5 smooth sbezier with lines title "10 concurrent requests", \
     "data/plot-apache-3.tsv" using 5 smooth sbezier with lines title "3 concurrent requests"
exit
