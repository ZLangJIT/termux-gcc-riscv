common="export MANPAGER=less ; export SHELL=/usr/bin/bash ; export TERMCOLOR=truecolor ; export TERM=xterm-256color ; export NIX_PATH=\\\"nixpkgs=/nixpkgs\\\" ; cd /termux_pwd"
if [ $# == 0 ] ; then
	cmd="-c"
	args="\"$common ; exec bash\""
else
	cmd="-c"
	args="\"$common ; $@\""
fi

export TERMUX_PREFIX=$(cd ; cd ../.. ; pwd)
eval proot-distro login ubuntu \
	--isolated --bind "$(pwd):/termux_pwd" \
	-- env -i bash -i $cmd $args
