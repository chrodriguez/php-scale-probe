# Let's output to a jpeg file
#set terminal jpeg size 1280,768
set terminal jpeg size 640,480
# This sets the aspect ratio of the graph
set size 1, 1
# The file we'll write to
set output "graphs/lb-multiple-servers-2.jpg"
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
stats 'data/lb-1-apache-10.tsv' every ::2 using 5 nooutput name 'X1_'
stats 'data/lb-2-apache-10.tsv' every ::2 using 5 nooutput name 'X2_'
stats 'data/lb-10-apache-10.tsv' every ::2 using 5 nooutput name 'X10_'
# Plot the data
plot "<(tail -n +2 data/lb-1-apache-10.tsv | sort -n -k 9)" every ::2 using ($5/1000):(100*$0/X1_records) smooth sbezier with lines t '1 backend' lw 2, \
     "<(tail -n +2 data/lb-2-apache-10.tsv | sort -n -k 9)" every ::2 using ($5/1000):(100*$0/X2_records) smooth sbezier with lines t '2 backends' lw 2, \
     "<(tail -n +2 data/lb-10-apache-10.tsv | sort -n -k 9)" every ::2 using ($5/1000):(100*$0/X10_records) smooth sbezier with lines t '10 backends' lw 2
exit
