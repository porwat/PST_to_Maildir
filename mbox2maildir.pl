#! /usr/bin/perl
# put into the public domain by Bruce Guenter <bruceg@em.ca>
# based heavily on code by Russell Nelson <nelson@qmail.org>, also in
# the public domain
# NO GUARANTEE AT ALL
#
# Creates a maildir from a mbox file

# Assumes that nothing is trying to modify the mailboxe
# version 0.00 - first release to the public.

sub error {
    print STDERR join("\n", @_), "\n";
    exit(1);
}

sub usage {
    print STDERR "usage: mbox2maildir <mbox file> <maildir> [ <uid> <gid> ]\n";
    exit(@_);
}

&usage(1) if $#ARGV != 1 && $#ARGV != 3;;

$mbox = $ARGV[0];
$mdir = $ARGV[1];
$uid = $ARGV[2];
$gid = $ARGV[3];

&error("can't open mbox '$mbox'") unless
    open(SPOOL, $mbox);

-d $mdir || mkdir $mdir,0700 ||
    &error("maildir '$mdir' doesn't exist and can't be created.");
chown($uid,$gid,$mdir) if defined($uid) && defined($gid);
chdir($mdir) || &error("fatal: unable to chdir to $mdir.");
-d "tmp" || mkdir("tmp",0700) || &error("unable to make tmp/ subdir");
-d "new" || mkdir("new",0700) || &error("unable to make new/ subdir");
-d "cur" || mkdir("cur",0700) || &error("unable to make cur/ subdir");
chown($uid,$gid,"tmp","new","cur") if defined($uid) && defined($gid);

$stamp = time;
sub open_msg {
    my($flags,$header) = @_;
    if($flags) {
        if($flags =~ /RO/) { $fn = "cur/$stamp.$$.mbox:2,S"; }
	elsif($flags =~ /O/) { $fn = "cur/$stamp.$$.mbox"; }
	else { $fn = "new/$stamp.$$.mbox"; }
    } else {
        $fn = "new/$stamp.$$.mbox";
    }
    $stamp++;
    close(OUT);
    open(OUT, ">$fn") || &error("unable to create new message");
    chown ($uid,$gid,$fn) if defined($uid) && defined($gid);
    print OUT @$header, "\n";
}

$in_header = 0;
while(<SPOOL>) {
    if(/^From /) {
        open_msg($flags, \@header) if $in_header;
	undef $flags;
	undef @header;
	$in_header = 1;
	push @header, "MBOX-Line: $_";
    } elsif($in_header) {
	if(/^\s+$/o) {
	    $in_header = 0;
	    open_msg($flags, \@header);
	} else {
            $flags = $1 if /^Status:\s+(\S+)/oi;
	    push @header, $_;
        }
    } else {
        s/^>From /From /;
        print OUT || &error("unable to write to new message");
    }
}
close(SPOOL);
open_msg($flags, \@header) if $in_header;
close(OUT);
