# QBT Manifest Repository

What is this?  This repository is a QBT manifest repository.  QBT is an
open-source dependency management and repostiory stiching tool.  Think of QBT
as being similar to the android development tool "repo", or git with
submodules, but with many additional features and benefits.

# What is this repository?

This repository, "meta", is the repository where the metadata for qbt
development is stored.  You can think of this as the parent or root repo in the
constellation of repos (including many satelite repos) that are used to build
QBT.  This is the repository where github issues, pull requests, and everything
else relating to QBT development happens.  Because of how QBT works, most of
the actual code lives elsewhere, but all workflows *start* here.

# Where is the code?

QBT works by having an external metadata file in a separate metadata repository
(usually called "meta") which refers to specific commits by sha1 in each code
repository ("satelites").  If you want to inspect the code, or build it, you
need to find the metadata repository (which if you are reading this, you have
already done) and clone it, then run QBT.  Usually, but not always, sattelite
repositories are located next to the metadata repository on the server.

To enable easier code-browsing, some qbt developers also push satelite branches
to github, but you should think of these repos as read-only.  One example is
the qbt repo [here](https://github.com/TerabyteQbt/qbt).  Notice that because
this is just a satelite repo, it has no README and the value of HEAD is not
authoritative.  To interact with this code in any way, you should use qbt and
the meta repo.

# Why do it this way?

For reproducibility, the version specified in the metadata must be
authoritative, but branches can be changed on the server and cannot themselves
be versioned, so instead QBT uses a concept called "pins".  The code in the
satelite is pushed ("pinned") to refs/qbt-pins/X where X is the sha1 of the
commit.  Because the branch itself is content-addressed, it can always be found
(and should never be deleted, just like git objects).  Because pins function
like entries in a content-addressible database, they can be pushed in any order
and at any time, as long as it preceeds the update to the meta repo which
references them, which is atomic.

If you need to manually inspect the code, you can see the branches in the
sattelite repositories using ls-remote:

    git ls-remote <clone URL>

By examining the manifest file, you could manaully do what QBT does and stitch
together a collection of clones with the appropriate sha1 checked out.  It's
all very transparent.  Perhaps some day someone will write a bootstrapping
script to do exactly this so people can build QBT without QBT.

The best way to view the code is to use QBT.  For details, see [The Qbt Website](https://qbtbuildtool.com).

# Under what license is QBT made available?

QBT is released under [The Unlicense](http://unlicense.org/).  The license file is [here](UNLICENSE).

Some code built by QBT, or upon which QBT depends, may be released under other
licenses, so check the satelite repositories and packages themselves for
license information.



