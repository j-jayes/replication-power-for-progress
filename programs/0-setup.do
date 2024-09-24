
* set wd
cd "/Users/jonathanjayes/Documents/PhD/replication-power-for-progress"

* create output directory
global output_dir "output"
cap mkdir $output_dir

* set distance cutoff
global distance_cutoff = 300

* install packages
ssc install estout
