#!/usr/bin/perl
#
# shows the inconsistency with decimal precision
# 

$i=534518;
$j=534517.6;

$k=$i - $j;
print "$k\n";
$k=$k*10;
print "$k\n";


if (($i-$j)*10>4){
print "AAAA\n";
}
