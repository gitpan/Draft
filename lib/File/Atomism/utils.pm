package File::Atomism::utils;

=head1 NAME

File::Atomism::utils - Misc file handling stuff

=head1 SYNOPSIS

Utilities for manipulating and creating filenames.

=head1 DESCRIPTION

A collection of standard perl functions and utilities for messing
with filenames.  These are generally useful for manipulating files
in an 'atomised' directory, see L<File::Atomism>.

=cut

use strict;
use warnings;

use File::stat;
use File::Spec;
use Sys::Hostname;
use Exporter;

use vars qw /@ISA @EXPORT_OK/;
@ISA = qw /Exporter/;
@EXPORT_OK = qw /Hostname Pid Inode Unixdate Dir File Extension TempFilename PermFilename/;

=pod

=head1 USAGE

Access some values useful for constructing temporary filenames:

   my $hostname = Hostname();
   my $pid = Pid();
   my $unixdate = Unixdate();

=cut

sub Hostname
{
    eval {Sys::Hostname::hostname} || 'localhost.localdomain';
}

sub Pid
{
    $$;
}

sub Unixdate
{
    time;
}

=pod

Retrieve the inode of a file like so:

    my $inode = Inode ('/path/to/my-house.jpg');

=cut

sub Inode
{
    my $filename = shift;
    my $stat = stat ($filename) || return 0;
    $stat->ino;
}

=pod

Access the directory and filename given a path:

    Dir ('/path/to/my-house.jpg');
    File ('/path/to/my-house.jpg');

.returns '/path/to/' and 'my-house.jpg' respectively.

=cut

sub Dir
{
    my $path = shift;
    my ($volume, $dir, $file) = File::Spec->splitpath ($path);
    return $dir;
}

sub File
{
    my $path = shift;
    my ($volume, $dir, $file) = File::Spec->splitpath ($path);
    return $file;
}

=pod

Retrieve the file extension (.doc, .txt, .jpg) of a file like so:

    my $extension = Extension ('my-house.jpg');

=cut

sub Extension
{
    my $filename = shift;
    return 0 unless ($filename =~ /[^.]\.[a-z0-9_]+$/);
    $filename =~ s/.*\.//;
    $filename =~ s/[^a-z0-9_]//gi;
    return $filename;
}

=pod

Ask for a temporary filename like so:

    my $tempname = TempFilename ('/path/to/');
or
    my $tempname = TempFilename ('/path/to/myfile.yml');

A unique filepath based on the directory, hostname, current PID and
extension (if supplied, otherwise .tmp will be appended) will be
returned:

    /path/to/.foo.example.com-666.tmp
    /path/to/.foo.example.com-666.yml

=cut

sub TempFilename
{
    my $path = shift;
    my $ext = Extension ($path) || 'tmp';

    Dir ($path) .".". Hostname ."-". Pid .".". $ext;
}

=pod

Ask for a permanent filename like so:

    my $filename = PermFilename ('/path/to/.foo.example.com-666.yml');

A unique filepath based on the hostname, current PID, inode of the
temporary file, date and file extension will be supplied:

    /path/to/foo.example.com-666-1234-1095026759.yml

Alternatively you can specify the final extension as a second
parameter:

    my $filename = PermFilename ('/path/to/.foo.example.com-666.tmp', 'yml');

=cut

sub PermFilename
{
    my $path = shift;
    my $ext = shift || Extension ($path);

    Dir ($path) . Hostname ."-". Pid ."-". Inode ($path) ."-".  Unixdate .".". $ext;
}

1;
