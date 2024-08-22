## Copyright 2023 SUSE LLC
# SPDX-License-Identifier: GPL-2.0-or-later

# Summary: This module use yupdate patch the Agama on Live Medium
# Maintainer: QE YaST and Migration (QE Yam) <qe-yam at suse de>

use base Yam::agama::patch_agama_base;
use strict;
use warnings;
use testapi;
use Utils::Architectures 'is_s390x';

sub run {
    unless (is_s390x) {
        assert_screen('agama-product-selection', 120);
        select_console 'root-console';
    }

    my ($repo, $branch) = split /#/, get_required_var('YUPDATE_GIT');
    assert_script_run("yupdate patch $repo $branch", timeout => 60);
}

1;
