#!/usr/bin/perl
# 
# last modified 2012-01-10 Jeff Edlund
# 
# script to add remote printer via lpadmin 
#
# after running check files:
#           /etc/hosts
#           /sm8/TERM.store0#
# test print queue:
#           lpq -P lp0##
#

use strict;
use warnings;
use File::Copy;
use IO::Handle;

my $_DEBUG           = "TRUE";
my $this_program_pid = $$;
my $uname            = `/bin/uname -r`; chomp($uname);
my $twhostname       = `/bin/hostname`; chomp($twhostname);
my $adminemail       = "jedlund" . '@' . "thriftywhite.com";

my $PID_FILE         = "/tmp/tmp_addprinter" . "$this_program_pid" . ".pid";
my $LPADMIN_PID_FILE = "/tmp/tmp_lpadmin.pid";
my $_LOG             = "/tmp/${twhostname}_addprinter.log";
my $previous_log_message = "";
my $lp_opts     = "";

########################################################

my $ip_to_add = "192.168.165.11";           # IP to add
my $print_queue = "lp088";        # Printer name to add
my $TWRX_PRINTER = "S88";
my $fh_w_hosts;               # File handler for writing hosts
my $fh_w_term;               # File handler for writing TERM.store02
my $hosts_file_read = "/etc/hosts";       # Original file
my $hosts_file_write = "/etc/hosts.new";  # File to write out
my $hosts_file_backup = "/etc/hosts.bak"; # File to copy original to
my $term_file_read = "/sm8/TERM.store02";        
my $term_file_write = "/sm8/TERM.store02.new";   
my $term_file_backup = "/sm8/TERM.store02.bak";  

########################################################

# user must have root access 
my $UID = `/usr/bin/id -u`; chomp($UID);
if ( "$UID" ne "0" ) {
    &log_it("User doesn't have root access", "ERROR");
}

# create a file that contains the PID of this program
open pid_file, "> ${PID_FILE}";
print pid_file "${this_program_pid}\n";
close pid_file;

# Make backup files   
copy("$hosts_file_read","$hosts_file_backup") 
                    or &log_it( "Cant copy $hosts_file_read: $!", "ERROR" );
copy("$hosts_file_read","$hosts_file_write") 
                    or &log_it( "Cant copy $hosts_file_read: $!", "ERROR" );
copy("$term_file_read","$term_file_backup")
                    or &log_it( "Cant copy $term_file_read: $!", "ERROR" );
copy("$term_file_read","$term_file_write") 
                    or &log_it( "Cant copy $term_file_read: $!", "ERROR" );

# Open File Handlers
open( $fh_w_hosts, '>>', $hosts_file_write ) 
                    or &log_it( "Cant copy $hosts_file_write: $!", "ERROR" );
open( $fh_w_term, '>>', $term_file_write ) 
                    or &log_it( "Cant copy $term_file_write: $!", "ERROR" );

# add new ip and hostname
print $fh_w_hosts "$ip_to_add     $print_queue\n"; 
# add new S## printer entry  (ie. S88)
#  ex.) DEFINE-DEVICE device=PRINTS88 path="lp -s -dlp088" pipe=yes
print $fh_w_term "DEFINE-DEVICE device=PRINT${TWRX_PRINTER} path=\"lp -s -d${print_queue}\" pipe=yes\n";

# Close file handers
close $fh_w_hosts;
close $fh_w_term;

# Moves new file to original file location
move("$hosts_file_write","$hosts_file_read");  
move("$term_file_write","$term_file_read");  


#################
# run lpadmin 
# ex.)  lpadmin -p lp088 -o printer-error-policy=retry-job -v "lpd://lp088/lp088" -E 
if ( $uname eq "2.6.22.14-72.fc6" || $uname eq "2.6.20-1.2320.fc5smp" ||  $uname eq "2.6.34.8-68.fc13.x86_64") {
    $lp_opts = " -o printer-error-policy=retry-job ";  # add option for later releases of cups
}
open LPADMIN_PID_FILE, "> ${LPADMIN_PID_FILE}";
my $open_pid = open( LPADMINPROC, 
    "lpadmin -p ${print_queue}  ${lp_opts} -v lpd://${print_queue}/${print_queue} -E  2>&1 | ");
&log_it("lpadmin command: lpadmin -p $print_queue ${lp_opts} -v lpd://${print_queue}/${print_queue} -E ", "INFO");
print LPADMIN_PID_FILE "${open_pid}\n";
close(LPADMIN_PID_FILE);
my @LPADMIN_RETURN_ARGS = <LPADMINPROC>;    # grab for any errors??
close(LPADMINPROC);
my $lpadmin_cmd_output;
for $lpadmin_cmd_output (@LPADMIN_RETURN_ARGS) {
    &log_it( "$lpadmin_cmd_output", "INFO" );
}

            
# now quit
&_quit_(0);    

# ------------- Start of subrountines ---------------- #
########################################################
sub log_it {
    my $log_message = $_[0];
    my $log_level   = $_[1];
    my @Month_name  = (
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    );
    ( my $sec, my $min, my $hour, my $day, my $month, my $year ) =
      (localtime)[ 0, 1, 2, 3, 4, 5 ];

    open( LOG_FILE, ">> ${_LOG}" );
    LOG_FILE->autoflush(1);

    # only log message if it is NOT the same as the last message
    if ( "$previous_log_message" ne "$log_message" ) {
        my $datetime = sprintf "%02d:%02d:%02d %04d %s %02d ::",
          $hour, $min, $sec, $year + 1900, $Month_name[$month], $day;
        if ( "$_DEBUG" eq "TRUE" ) {
            print LOG_FILE
              "${log_level}:: ${datetime} ${log_message}\n";    # log all messages
        }
        else {    # log level is : INFO
            if ( "$log_level" eq "INFO" ) {
                print LOG_FILE "${log_level}:: ${datetime} $log_message";
            }
        }
                    
        if ( "$log_level" eq "ERROR" ) {
             &emailerror("${datetime} : $log_message");
             &_quit_(2);
        }
        

        $previous_log_message = $log_message;
    }

    close(LOG_FILE);

}

########################################################
sub _quit_ {

    # $_[0] is the error code passed to the subroutine
    my $error_code = "";
    $error_code = $_[0];

    if ( $error_code == 0 ) {
        &log_it( "addprinter.pl exited normally.\n", "INFO" );
    }
    else {
        &log_it("ERROR: addprinter.pl exited with Error_Code=${error_code}.\n", "DEBUG" );
        &emailerror("ERROR: addprinter.pl exited with Error_Code=${error_code}.");
    }

    # exit with the Error_Code (the value passed to the subroutine _quit_)
    exit($error_code);
}

########################################################
sub emailerror {
    my $msg = $_[0];
    # email error to $adminemail

    my $sendmail = "/usr/sbin/sendmail -t ";
    my $reply_to = "Reply-to: root" . '@' . "${twhostname}\n";
    my $subject  = "Subject: addprinter.pl script ERROR at ${twhostname} \n";
    my $content = " ***** Immediate attention required!!  *****\n\n"
      . "There has been an addprinter.pl script ERROR at ${twhostname} \n\n"
      . "${msg} \n";
    my $send_to = "To: ${adminemail}\n\n";
    open( SENDMAIL, " | $sendmail" ) or die "Cannot open $sendmail: $!";
    print SENDMAIL $reply_to;
    print SENDMAIL $subject;
    print SENDMAIL $send_to;    #print SENDMAIL 'Content-type: text/plain\n\n';
    print SENDMAIL $content;
    close(SENDMAIL);

}
#
# history
# --------
# 2012-01-10 minor fixes
# 2011-05-05 created
# 
