# Copyright 2022 SUSE LLC
# SPDX-License-Identifier: GPL-2.0-or-Later
#
# Summary: Test vsftpd with ssl enabled
# Maintainer: QE Security <none@suse.de>
# Tags: poo#108614, tc#1769978

use base 'opensusebasetest';
use strict;
use warnings;
use testapi;
use utils;

sub check_hash {
    my ($expected_hash, $calculated_hash) = @_;
    my $message = ($expected_hash eq $calculated_hash) ? "Pass: Hash values matched" : "Error: Hash values did not match. Expected: $expected_hash, Got: $calculated_hash";
    record_info($message);
}

sub run {
    my $user = 'ftpuser';
    my $pwd = 'susetesting';
    my $ftp_users_path = '/srv/ftp/users';
    my $ftp_served_dir = 'served';
    my $ftp_received_dir = 'received';

    select_console 'root-console';

    # Install lftp
    zypper_call('in lftp');
    enter_cmd('echo "set ssl:verify-certificate no" >> /etc/lftp.conf');

    # Login to ftp server for downloading/uploading, first create a file for uploading
    assert_script_run('echo "QE Security" > f2.txt');
    enter_cmd("lftp -d -u $user,$pwd -e 'set ftp:ssl-force true' localhost");

    # Download file from server
    enter_cmd("get $ftp_served_dir/f1.txt");

    # Upload file to server
    enter_cmd("put -O $ftp_received_dir/ f2.txt");

    # Exit lftp
    enter_cmd('exit');

    # Check if file has been downloaded
    assert_script_run('ls | grep f1.txt');

    # Compare file hashes
    my $hash_orig = script_output("sha256sum $ftp_users_path/$user/$ftp_served_dir/f1.txt");
    my $hash_downloaded = script_output('sha256sum f1.txt');
    check_hash($hash_orig, $hash_downloaded);

    # Check if file has been uploaded
    assert_script_run("ls $ftp_users_path/$user/$ftp_received_dir | grep f2.txt");

    # Compare file hashes
    my $hash_created = script_output('sha256sum f2.txt');
    my $hash_uploaded = script_output("sha256sum $ftp_users_path/$user/$ftp_received_dir/f2.txt");
    check_hash($hash_created, $hash_uploaded);
}

1;
