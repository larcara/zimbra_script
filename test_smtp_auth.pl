#!perl

use warnings;
use strict;

use Net::SMTP;

my $num_args = $#ARGV + 1;
if ($num_args != 6) {
    print "\nUsage: test_smtp.pl user password sender from to server\n";
    exit;
}

my $smtpserver = $ARGV[5];
my $smtpuser   = $ARGV[0];
my $smtppassword = $ARGV[1];
my $sender  = $ARGV[2];
my $fromemail  = $ARGV[3];
my $toemail  = $ARGV[4];

my $smtp = Net::SMTP->new($smtpserver, Timeout => 10, Debug => 2, SSL => 1);
die "Could not connect to server!\n" unless $smtp;

  $smtp->hello();
  $smtp->auth($smtpuser, $smtppassword) or die "Could not authenticate $smtpuser  $!";
  $smtp->mail($sender);
  $smtp->to($toemail);
  $smtp->data();
  $smtp->datasend("To: $toemail\n");
  $smtp->datasend("From: $fromemail\n");
  $smtp->datasend("\n");
  $smtp->datasend("Body message\n");
  $smtp->dataend();
  $smtp->quit;
