#
# Copyright (C) 2002 by Peder Stray <peder@ninja.no>
#

use strict;
use Irssi 20021204.1123;

# ======[ Script Header ]===============================================

use vars qw{$VERSION %IRSSI};
($VERSION) = '$Revision: 1.2 $' =~ / (\d+\.\d+) /;
%IRSSI = (
	  name        => 'upgradeinfo',
	  authors     => 'Peder Stray',
	  contact     => 'peder@ninja.no',
	  url         => 'http://ninja.no/irssi/upgradeinfo.pl',
	  license     => 'GPL',
	  description => 'Statusbaritem notifying you about updated binary',
	 );

# ======[ Variables ]===================================================

my($load_time) = 0;		# modification time of binary at load
my($file_time) = 0;		# modification time of binary file
my($timer) = 0;			# ID of current timer

# ======[ Commands ]====================================================

# --------[ UPGRADEINFO ]-----------------------------------------------

sub cmd_upgradeinfo {
    my($param,$serv,$chan) = @_;

    print CLIENTCRAP sprintf ">> load: %s", scalar localtime $load_time;
    print CLIENTCRAP sprintf ">> file: %s", scalar localtime $file_time;

}

# ======[ Signal Hooks ]================================================

# --------[ sig_setup_changed ]-----------------------------------------

sub sig_setup_changed {
    my($interval) = Irssi::settings_get_int('upgrade_check_interval');

    Irssi::timeout_remove($timer);

    if ($interval < 1) {
	$interval = 0;
    }

    return unless $interval;

    $interval *= 1000;
    $timer = Irssi::timeout_add($interval, 'ui_check' , undef);
}

# ======[ Statusbar Hooks ]=============================================

# --------[ sb_upgradeinfo ]--------------------------------------------

sub sb_upgradeinfo {
    my($item, $get_size_only) = @_;
    my $format = "";
    my($time);

    $time = $file_time - $load_time;

    if ($time) {
	$time = sprintf("%dd%02dh%02dm%02ds",
			$time/60/60/24,
			$time/60/60%24,
			$time/60%60,
			$time%60
		       );
	$time =~ s/^(0+\D)+//;
	$format = "{sb %r$time%n}";
    }

    $item->default_handler($get_size_only, $format, undef, 1);
}

# ======[ Timers ]======================================================

# --------[ ui_check ]--------------------------------------------------

sub ui_check {
    $file_time = (stat Irssi::get_irssi_binary)[9];

    Irssi::statusbar_items_redraw('upgradeinfo');
}

# ======[ Setup ]=======================================================

# --------[ Register commands ]-----------------------------------------

Irssi::command_bind('upgradeinfo', 'cmd_upgradeinfo');

# --------[ Register formats ]------------------------------------------

# --------[ Register settings ]-----------------------------------------

Irssi::settings_add_int('upgrade', 'upgrade_check_interval', 300);

# --------[ Register signals ]------------------------------------------

Irssi::signal_add('setup changed', 'sig_setup_changed');

# --------[ Register statusbar items ]----------------------------------

Irssi::statusbar_item_register('upgradeinfo', undef, 'sb_upgradeinfo');

# --------[ Other setup ]-----------------------------------------------

$load_time = (stat Irssi::get_irssi_binary)[9];

sig_setup_changed;

# ======[ END ]=========================================================

# Local Variables:
# header-initial-hide: t
# mode: header-minor
# end:
