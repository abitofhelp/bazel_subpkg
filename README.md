# bazel_subpkg

This is a monorepo project that contains a single package, "abc", which contains some subpackages.
I am trying to figure out the following:

* Do I have to have a BUILD.bazel file in each directory containing .go files within the 'abc' directory and its subdirectories? It seems like a lot of work when I only want to collect all of the .go files
under 'abc' into a library that can be shared.


* Package 'date' does not use package 'constants', but Bazel indicates "package date; expected constants". I have no idea what to do...


* Directory 'nobuildfile' contains hello.go but no BUILD.bazel file.  I want to include 'hello.go' in the 'abc' package. It is an experiment to see what happens when a directory under 'abc' is not subpackage. The Bazel build "package nobuildfile; expected constants".  However, there is no BUILD.bazel file, so it isn't a package, right?  Also, I don't know what the error indicates since hello.go does not use the contants' package. 
