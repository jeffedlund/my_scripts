#!/usr/bin/perl
#
# Description:
#     Perl script that starts Java process
#         (which is wrapped in JarFiletoExec.jar)
#
use warnings;
use strict;
use File::Basename;
use File::Copy;
use IO::Handle;

my $_DEBUG = "FALSE";
my $this_program_pid = $$;
my $twhostname = `/bin/hostname`;
chomp($twhostname);
my $adminemail = "root" . '@' . "localhost";
my $EP_BASE="/mybasedirectory";
my $JAVABIN="/usr/java/current/bin";
my $JARPATH="${EP_BASE}/client";
my ${JAVAARGS}="-Djava.net.preferIPv4Stack=true";

my $PID_FILE = "${EP_BASE}/var/PSMONITOR.PID";
# create a file that contains the PID of this program
open pid_file, "> ${PID_FILE}";
print pid_file "${this_program_pid}\n";
close pid_file;

########################################################
my @TW_FILES;
my @JAVA_PROCESS_RETURN_ARGS;
my $edifact_file;
my $counter;
my $last_arg;
my $open_pid;
my $get_ps_out_pid;
my $check_process;
my @properties1;
my $status = "RUNNING";
my $filefound = "false";
my $previous_log_message = "";
my $JAVA_PID_FILE ="${EP_BASE}/var/JAVA_CLIENT.PID";
my $MONITOR_PROC_FILE = "${EP_BASE}/var/.MONITOR.PROC";
my $_LOG="${EP_BASE}/log/psmonitor.log";

########################################################
#my $PROPERTIES_FILE = "${JARPATH}/epclient.properties" ;
#open PROPS, "$PROPERTIES_FILE";
#@properties1 = <PROPS>;
#close(PROPS);

########################################################
############### variables for getEdiFactFile ###########
my $out_file_base = "/usr/eps/out";
chomp($out_file_base);
my $_filename_ = "";
my $current_filename = "";
########################################################

&log_it("psmonitor.pl PID is: ${this_program_pid}\n", "INFO");

# the main loop
while ( "$status" eq "RUNNING") {

    # populate PROC file
   open MONITOR_PROC, "> ${MONITOR_PROC_FILE} " ;
   print MONITOR_PROC "${status}\n" ;
   close(MONITOR_PROC);

    &get_ediFactFileName;

    # pause 2 seconds and restart while loop
    if ( "$filefound" eq "false" ) {
	&log_it("Checked /usr/eps/out ... No EDIFACT file(s) found. \n", "DEBUG");
        sleep(2);
        &_checkstatus;
        next;
    } else {
    # we've found a file in /usr/eps/out
        &log_it("INFO: File(s) found in /usr/eps/out directory. \n", "INFO");
        for $_filename_ (@TW_FILES) {
            chomp($_filename_);
            $current_filename = $_filename_;
            #
            &log_it("Running java -jar JarFiletoExec.jar : with arg: ${out_file_base}/${_filename_}\n", "INFO");
            # run java -jar JarFiletoExec.jar to process 
            #
            $open_pid = open(JAVAPROC, "${JAVABIN}/java ${JAVAARGS} -jar ${JARPATH}/JarFiletoExec.jar ${out_file_base}/${_filename_} 2>&1 |");
            #
            JAVAPROC->autoflush(1);
            open JAVA_PID_FILE, "> ${JAVA_PID_FILE}";
            print JAVA_PID_FILE "${open_pid}\n";
            close(JAVA_PID_FILE);
            # log output of java process
            while (<JAVAPROC>) {
                &log_it("$_", "INFO");
            }
            close(JAVAPROC);
            my $exit_code=$?;    # check for errors and exit if any
            &log_it("Java process exit code: $exit_code \n", "INFO");
            if ( "$exit_code" ne "0" ) {
                &_quit_($exit_code);
            }
            #
            &deletefile(${_filename_});
        }

    }
&_checkstatus;

} # end of loop
# now quit
&_quit_(0);

# ------------- Start of subrountines ---------------- #
########################################################
sub log_it {
    my $log_message = $_[0] ;
    my $log_level   = $_[1] ;
    my @Month_name = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep",
                    "Oct", "Nov", "Dec");
    (my $sec, my $min, my $hour, my $day, my $month, my $year)
                    = ( localtime ) [ 0, 1, 2, 3, 4, 5 ];

    open (LOG_FILE, ">> ${_LOG}") ;
    LOG_FILE->autoflush(1);

   # only log message if it is NOT the same as the last message
    if ( "$previous_log_message" ne "$log_message" ) {
            my $datetime = sprintf "%02d:%02d:%02d %04d %s %02d ::",
                    $hour, $min, $sec, $year+1900, $Month_name[$month], $day ;
        if ("$_DEBUG" eq "TRUE") {
            print LOG_FILE "${log_level}:: ${datetime} ${log_message}";  # log all messages
        } else {   # log level is : INFO
            if ("$log_level" eq "INFO") {
                print LOG_FILE "$log_message";
            }
        }

        $previous_log_message = $log_message;
    }

    close(LOG_FILE);

}
########################################################
sub _checkstatus {

    open MONITOR_PROC, "< ${MONITOR_PROC_FILE} " ;
    $check_process = <MONITOR_PROC>;
    chomp $check_process;
    close(MONITOR_PROC);

    # exit if psmonitord service termination was requested
    if ( "$check_process" eq "EXIT" ) {
        &log_it("Exit was requested by psmonitord\n", "INFO");
        $status = "EXIT";
        # clear PROC file
        open MONITOR_PROC, "> ${MONITOR_PROC_FILE} " ;
        print MONITOR_PROC "STOPPED\n" ;
        $status = "STOPPED";
        close(MONITOR_PROC);
    }

    &log_it("Status is: ${status} \n", "DEBUG");

}

########################################################
sub get_ediFactFileName {

    # check to see if TW file exists.
    opendir(DIR, "${out_file_base}");
    # Ignore .tmp files
    ## @TW_FILES = grep(!/\.tmp$/, readdir(DIR));
    @TW_FILES = grep(/\.[0-9][0-9][0-9]$/, readdir(DIR));
    closedir(DIR);

    # trim all FILES if necessary
    foreach (@TW_FILES) {
        chomp($_);
        #print "$_ \n";
    }

    if(@TW_FILES < 1 ) {
        # file not found.
        $filefound = "false";
    } else {
    $filefound = "true";
    }

}

########################################################
sub deletefile {
    # Make backup copy before delete
    copy("${out_file_base}/$_[0]", "${EP_BASE}/tmp") or &log_it("Couldn't copy ${out_file_base}/$_[0] to ${EP_BASE}/tmp directory! \n", "INFO");
    # delete /usr/eps/out file that was just processed
    if ( -r "${out_file_base}/$_[0]" ) {
            unlink( "${out_file_base}/$_[0]" )
                or warn "can't delete ${out_file_base}/$_[0] \n";
    } else {
       &log_it("Couldn't delete ${out_file_base}/$_[0] \n", "DEBUG");
    }
}

########################################################
sub _quit_ {
    # $_[0] is the error code passed to the subroutine
    my $error_code = "" ;
    $error_code = $_[0] ;

    if ( "${error_code}" eq "0" ) {
        &log_it("psmonitor.pl exited normally.\n", "INFO") ;
    } else {
        &log_it("ERROR: psmonitor.pl exited with Error_Code=${error_code}.\n", "DEBUG") ;
        &emailerror;
    }


# exit with the Error_Code (the value passed to the subroutine _quit_)
exit($error_code);
}

########################################################
sub emailerror {
   # email error to $adminemail

 my $sendmail = "/usr/sbin/sendmail -t ";
 my $reply_to = "Reply-to: root" . '@' . "${twhostname}\n";
 my $subject = "Subject: ePrescribe Error at ${twhostname} \n";
 my $content = " ***** Immediate attention required!!  *****\n\n"
              . "There's been an JarFiletoExec Error at ${twhostname}\n"
              . "while processing file:\n"
              . "${current_filename}\n\n";
 my $send_to = "To: ${adminemail}\n\n";
 open(SENDMAIL, " | $sendmail") or die "Cannot open $sendmail: $!";
 print SENDMAIL $reply_to;
 print SENDMAIL $subject;
 print SENDMAIL $send_to;        #print SENDMAIL 'Content-type: text/plain\n\n';
 print SENDMAIL $content;
 close(SENDMAIL);

}
