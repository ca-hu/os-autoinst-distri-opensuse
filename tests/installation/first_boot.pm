# SUSE's openQA tests
#
# Copyright 2009-2013 Bernhard M. Wiedemann
# Copyright 2012-2020 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Summary: Special handling to get to the desktop the first time after
#          the installation has been completed (either find the desktop after
#          auto-login or handle the login screen to reach the desktop)
# - Wait for login screen
# - Handle displaymanager
# - Handle login screen
# - Check if generic-desktop was reached
# Maintainer: Max Lin <mlin@suse.com>

use strict;
use warnings;
use base 'bootbasetest';
use testapi;
use x11utils 'turn_off_plasma_tooltips';

sub run {
    shift->wait_boot_past_bootloader;
    # This only works with generic-desktop. In the opensuse-welcome case,
    # the opensuse-welcome module will handle it instead.
    turn_off_plasma_tooltips if match_has_tag('generic-desktop');
}

sub test_flags {
    return {fatal => 1, milestone => 1};
}

# 'generic-desktop' already checked in wait_boot_past_bootloader
sub post_run_hook { }

sub post_fail_hook {
    my ($self) = shift;
    select_console 'root-console';
    upload_logs('/var/log/audit/audit.log');
    script_run('journalctl > /tmp/logs_jour.txt');
    upload_logs('/tmp/logs_jour.txt');
    $self->SUPER::post_fail_hook;
    upload_logs('/etc/hosts');
}

1;
