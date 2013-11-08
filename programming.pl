#!/usr/bin/perl
#
# Run as:
# perl programming.pl -a --machine remote /etc and this is the output:
# 
#     $VAR1 = [
#     '-a',
#     '--machine',
#     'remote',
#     '/etc'
#     ];
#

use strict;
use warnings;
use Data::Dumper qw(Dumper);
 
print Dumper \@ARGV;

