# SUSE's openQA tests
#
# Copyright © 2009-2013 Bernhard M. Wiedemann
# Copyright © 2012-2018 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: Boot from existing image to desktop
# Maintainer: mitiao <mitiao@gmail.com>

use base 'opensusebasetest';
use strict;
use testapi;
use version_utils qw(is_upgrade is_sles4sap);

sub run {
    my ($self) = @_;
    $self->{in_boot_desktop} = 1;
    # We have tests that boot from HDD and wait for DVD boot menu's timeout, so
    # the timeout here must cover it. UEFI DVD adds some 60 seconds on top.
    my $timeout = get_var('UEFI') ? 140 : 80;
    # Do not attempt to log into the desktop of a system installed with SLES4SAP
    # being prepared for upgrade, as it does not have an unprivileged user to test
    # with other than the SAP Administrator
    my $nologin = (get_var('HDDVERSION') and is_upgrade() and is_sles4sap()) ? 1 : 0;
    if (check_var('VIRSH_VMM_TYPE', 'linux')) {
        wait_serial('Welcome to SUSE Linux', $timeout) || die "System did not boot in $timeout seconds.";
    }
    else {
        $self->wait_boot(bootloader_time => $timeout, nologin => $nologin);
    }
}

sub test_flags {
    # add milestone flag to save setup in lastgood VM snapshot
    return {fatal => 1, milestone => 1};
}

1;
