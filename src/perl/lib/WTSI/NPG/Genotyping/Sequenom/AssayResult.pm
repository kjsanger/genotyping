use utf8;

package WTSI::NPG::Genotyping::Sequenom::AssayResult;

use Moose;

with 'WTSI::NPG::Loggable';

has 'allele'        => (is => 'ro', isa => 'Str', required => 1);
has 'assay_id'      => (is => 'ro', isa => 'Str', required => 1);
has 'chip'          => (is => 'ro', isa => 'Str', required => 1);
has 'customer'      => (is => 'ro', isa => 'Str', required => 1);
has 'experiment'    => (is => 'ro', isa => 'Str', required => 1);
has 'genotype_id'   => (is => 'ro', isa => 'Str', required => 1);
has 'height'        => (is => 'ro', isa => 'Num', required => 1);
has 'mass'          => (is => 'ro', isa => 'Num', required => 1);
has 'plate'         => (is => 'ro', isa => 'Str', required => 1);
has 'project'       => (is => 'ro', isa => 'Str', required => 1);
has 'sample_id'     => (is => 'ro', isa => 'Str', required => 1);
has 'status'        => (is => 'ro', isa => 'Str', required => 1);
has 'well_position' => (is => 'ro', isa => 'Str', required => 1);
has 'str'           => (is => 'ro', isa => 'Str', required => 1);


=head2 normalized_call

  Arg [1]    : None

  Example    : $call = $result->normalized_call()
  Description: Method to return the genotype call, in a string representation
               of the form AA, AC, CC, or NN. Name and behaviour of method are
               intended to be consistent across all 'AssayResultSet' classes
               (for Sequenom, Fluidigm, etc).
  Returntype : Str

=cut

sub normalized_call {
    # require an input call of the form A, AC, C, or N
    my ($self) = @_;
    my $call = $self->genotype_id();
    if ($call =~ /[^ACGTN]/) {
        $self->logcroak("Characters other than ACGTN in genotype '$call'");
    } elsif (length($call) == 1) {
        $call = $call.$call; # homozygote or no call
    } elsif (length($call) == 2) {
        # heterozygote, do nothing
    } else {
        my $msg = "Illegal genotype call '$call' for sample ".
            $self->normalized_sample_id().", SNP ".self->normalized_snp_id();
        $self->logcroak($msg);
    }
    return $call;
}


=head2 normalized_sample_id

  Arg [1]    : None

  Example    : $sample_identifier = $result->normalized_sample_id()
  Description: Method to return the sample ID. Name and behaviour of method
               are intended to be consistent across all 'AssayResultSet'
               classes (for Sequenom, Fluidigm, etc).
  Returntype : Str

=cut

sub normalized_sample_id {
    my ($self) = @_;
    return $self->sample_id();
}


=head2 normalized_snp_id

  Arg [1]    : None

  Example    : $snp_identifier = $result->normalized_snp_id()
  Description: Method to return the SNP (assay) ID. Name and behaviour of
               method are intended to be consistent across all 'AssayResultSet'
               classes (for Sequenom, Fluidigm, etc).
  Returntype : Str

=cut

sub normalized_snp_id {
    my ($self) = @_;
    # assume assay_id of the form [plex name]-[snp name]
    my @terms = split("\-", $self->assay_id());
    my $snp_id = pop(@terms);
    return $snp_id;
}

sub snpset_name {
  my ($self) = @_;

  return $self->_split_assay_id->[0];
}

sub snp_assayed {
  my ($self) = @_;

  return $self->_split_assay_id->[1];
}

sub _split_assay_id {
  my ($self) = @_;

  my ($snpset_name, $snp_name) = split /-/, $self->assay_id;
  $snpset_name ||= '';
  $snp_name    ||= '';

  return [$snpset_name, $snp_name];
}

__PACKAGE__->meta->make_immutable;

no Moose;

1;

__END__

=head1 NAME

WTSI::NPG::Genotyping::Sequenom::AssayResult

=head1 DESCRIPTION

A class which represents a result of a Sequenom assay of one SNP for
one sample.

=head1 AUTHOR

Keith James <kdj@sanger.ac.uk>

=head1 COPYRIGHT AND DISCLAIMER

Copyright (c) 2014 Genome Research Limited. All Rights Reserved.

This program is free software: you can redistribute it and/or modify
it under the terms of the Perl Artistic License or the GNU General
Public License as published by the Free Software Foundation, either
version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

=cut
