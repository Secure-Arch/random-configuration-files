# thin_check
# Autogenerated from man page /usr/share/man/man8/thin_check.8.gz
complete -c thin_check -s q -l quiet -d 'Suppress output messages, return only exit code'
complete -c thin_check -s h -l help -d 'Print help and exit'
complete -c thin_check -s V -l version -d 'Output version information and exit'
complete -c thin_check -l super-block-only -d 'Only check the superblock'
complete -c thin_check -l skip-mappings -d 'Skip checking of the block mappings which make up the bulk of the metadata'
complete -c thin_check -l ignore-non-fatal-errors -d 'Will only return a non-zero exit code if it finds a fatal error. PP . nf '
complete -c thin_check -l clear-needs-check-flag -d 'Clears the \'needs_check\' flag in the superblock. PP . nf '
complete -c thin_check -l metadata-snapshot -s m -d 'Check the metadata snapshot. PP . nf '
complete -c thin_check -l auto-repair -d 'Automatically repair any trivial issues found with the metadata. PP . nf '
complete -c thin_check -l override-mapping-root -d 'Specify a mapping root to use.      Don\'t use this'

