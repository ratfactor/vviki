
= VViki Testing 1

Welcome to the first test document for VViki. The current filename should be
`test/current_doc.adoc` and it has been created by the test script.

Another script (`test/current_script.vim`) has already run, setting the wiki
test environment for this particular test. In this case, we're just going with
the defaults, so there's not much going on in the setup:

----
Test Script Start
echo "Hello! Test 1 uses defaults, so there's nothing to set."
Test Script End
----

== Test basic linking

Make sure this link looks like `Foo` with cursor off and `link:foo[Foo]` with
cursor over it. Hitting Enter should take you to the Foo page!

link:foo[Foo]

