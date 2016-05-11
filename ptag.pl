#!/usr/bin/perl -w

# ptag - Write psuedo-tags for files in a directory.
#
# Usage: ptag command
#
#        ptag tag <file> tag,tag,tag,tag
#

die "Unrecognized command. Please use 'ptag help'\n" if (scalar @ARGV < 1);

$db_open = 0;
$SIG{INT} = sub {
	close(TAGDB) if ($db_open == 1);
	exit 0;
};

$command = $ARGV[0];
if ($command eq 'search') {
	die "No tags provided.\n" if (scalar @ARGV < 2);

	@tag_criteria = split(',', $ARGV[1]);
	print "Searching...\n";

	# Read database and find tags.
	$results = 0;
	open(TAGDB, ".ptagdb") || die "Could not open ptag database. Does it even exist?\n";
	$db_open = 1;
	while ($line = <TAGDB>) {
		($file_name, $raw_tag_list) = $line =~ /(.+)\s*=\s*(.+)/;
		@file_tags = split(',', $raw_tag_list);

		for ($i = 0; $i < (scalar @tag_criteria); $i++) {
			$required_tag = $tag_criteria[$i];

			# See if the required tag is in the list.
			$has_required_tag = 0;
			for $tag (@file_tags) {
				$has_required_tag = 1 if ($tag eq $required_tag);
			}

			# If we didn't find it, then we must bail here.
			if ($has_required_tag == 0) {
				last;
			}

			# If this was the last tag, and we've reached here, then this is a query result.
			if ($i + 1 == (scalar @tag_criteria)) {
				print $file_name . "\n";
				$results++;
			}
		}
	}

	print "$results results.\n";
}

if ($command eq 'newdb') {

	@files = <*>;

	open(TAGDB, '>>', ".ptagdb") || die "Failed to open .ptagdb.\n";
	$db_open = 1;

	print "Will create a new database " . (scalar @files) . " files:\n";
	for $file (@files) {
		# We don't care to tag directories...
		next if (-d $file);

		# Ask for tags until we get them.
		$file_tags = "";
		while ($file_tags eq "") {
			print "Tags for " . $file . ":\n";
			$file_tags = <STDIN>;
			chomp $file_tags
		}
		print "\n";

		print TAGDB "$file = $file_tags\n";
	}

	print "Done!\n";
}

if ($command eq 'organize') {
	organize();
}

if ($command eq 'update') {
	update();
}

# Read entries from the ptag file.
#
# Returns a hash of the entries in the ptag database. File names are keys
# and their associated tag list is their value. The .ptagdb file is opened
# and read, then closed.
sub get_db_entries {
	open(TAGDB, '.ptagdb') || die "Failed to open .ptagdb.";
	while (my $line = <TAGDB>) {
		chomp $line;

		(my $file_name, my $tag_list) = $line =~ /(.+)\s*=\s*(.+)/;
		$file_name =~ s/\s+$//;

		# Place into hash.
		$ptagdb{$file_name} = $tag_list;
	}
	close(TAGDB);

	return %ptagdb;
}

# Sort the ptag file.
#
# Opens the .ptagdb file and reads the entries. It this writes these entries
# back out the file in alphabetical order by file name.
sub organize {
	%ptagdb = get_db_entries();

	# Sort and write back out.
	open(TAGDB, '>', '.ptagdb') || die "Failed to open .ptagdb.";
	$db_open = 1;
	for $key (sort(keys(%ptagdb))) {
		print TAGDB "$key = $ptagdb{$key}\n";
	}
	close(TAGDB);
	$db_open = 0;

	return;
}

# Prompts to add tags for new files.
#
# Reads the database and looks for new files in the directory to add. If
# a file is found that is not in the database, a prompt appears for it.
# Providing no input will cause it to continue to prompt for the same file
# until at least one tag is provided.
sub update {
	%ptagdb = get_db_entries();

	open(TAGDB, '>>', '.ptagdb') || die "Failed to open .ptagdb.";
	$db_open = 1;

	@files = <*>;
	for $file_name (@files) {
		# We don't care about directories.
		# We don't care about entries already present.
		if (-d $file_name || defined $ptagdb{$file_name}) {
			next;
		}

		$file_tags = "";
		while ($file_tags eq "") {
			print "Tags for " . $file_name . ":\n";
			$file_tags = <STDIN>;
			chomp $file_tags
		}
		print "\n";
		print TAGDB "$file_name = $file_tags\n";
	}

	close(TAGDB);
	$db_open = 0;
}

exit 0;
