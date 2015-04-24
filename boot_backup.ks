
copy "copy_files.ks" from 0.

run copy_files.

// check for boot file on archive

if 0 { // rename not working
run lib_util.

switch to 0.
local filename is util_boot_filename_arch(ship).

if util_file_exists(filename) {
	print filename + " found".
	copy filename to 1.
	rename file filename to "boot.ks".
} else {
	print filename + " not found".
}

switch to 1.
}

