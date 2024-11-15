set -x
if [[ -f nixpkgs.patch ]] ; then
	rm -v nixpkgs.patch
fi
R=$(cat git_reset_nixpkgs)
echo "patch file" > nixpkgs.patch
cd nixpkgs
if [[ -d dotgit ]] ; then
	mv -v dotgit .git
fi
git reset $R
git add -AN
git diff --binary $R >> ../nixpkgs.patch
mv -v .git dotgit
