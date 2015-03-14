# Noidman #
<p>
Noidman is a Ruby on Rails-based web application for creating, managing, validating, and resolving persistent identifiers.  It is built around the Archival Resource Key identifier schema and is essentially a web front-end for the Noid (nice opaque identifier) tool released by the California Digital Library.  Noidman thus depends upon the Perl-based Noid tool, wrapping its functions in a Ruby facade class, <a href='NoidRB.md'>Noid.rb</a>.<br>
</p>
<p>
Note that I do not intend to continue developing Noidman; the coupling with the Noid tool was too limiting, and so I'm pouring all of my development time into <a href='Arkham.md'>Arkham</a> instead.  Still, you may find the Noidman code useful and it's available now.<br>
</p>
<p>
Browse the <a href='http://code.google.com/p/noidman/source/browse/#svn/trunk'>source code</a> if you wish.<br>
</p>
<h2>Availability</h2>
<p>
You may check the code out freely:<br>
</p>
```
svn checkout http://noidman.googlecode.com/svn/trunk/ noidman-read-only  
```
<h2>License</h2>
<p>
Noidman is released under the <a href='LICENSE.md'>MIT/X11 license</a>.<br>
</p>
<h2>Documentation</h2>
<p>
You might be interested in <a href='NoidmanInstallation.md'>installation steps</a>.<br>
</p>