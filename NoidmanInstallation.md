# Noidman: Installation #

<p>
These are the steps I took to install Noidman and migrate releases into production.  Some steps are Gentoo-specific, and YMMV.<br>
</p>
<h2>Installation steps</h2>
<p>
Verify Perl 5.8 installed<br>
</p>
```
perl -v
```
<p>
Verify Ruby 1.8.4 installed<br>
</p>
```
ruby -v
```
<p>
Install Perl module (and its dependencies) for Noid<br>
</p>
```
cpan install Noid
```
<p>

Install required packages (BDB, Ruby-bdb, rails, fastcgi, etc.)<br>
</p>
```
emerge dev-perl/BerkeleyDB
emerge dev-ruby/rubygems
emerge dev-ruby/ruby-bdb
emerge dev-lang/swig
USE="-mysql" emerge dev-ruby/rails
emerge dev-libs/fcgi
emerge dev-ruby/ruby-fcgi
emerge net-www/mod_fastcgi
```
<p>
Edit Apache configs<br>
</p>
<ul><li>add "-D FASTCGI" to /etc/conf.d/apache2<br>
</li><li>create /etc/apache2/vhosts.d/arks_domain_tld.conf<br>
</li><li>include "AllowEncodedSlashes on" directive<br>
</li><li>add rewrite for noid resolution (See Noid documentation)<br>
</li><li>add rewrite for rails app<br>
</li><li>add FastCgiServer directive for static fcgi<br>
</li><li>move proxy directives into default vhost<br>
</li></ul><p>
Create passwd file for http basic auth<br>
</p>
```
/usr/sbin/htpasswd2 -c /etc/apache2/noidman.htpasswd USERNAME
```
<p>
Create folder for vhost content<br>
</p>
```
mkdir /var/www/arks
```
<p>
Set-up Noid in /var/www/arks/resolve<br>
</p>
<ul><li>see <a href='http://search.cpan.org/dist/Noid/noid'><span>Noid documentation</span></a>
</li></ul><p>
Checkout production code<br>
</p>
```
cd /var/www/arks
svn checkout http://noidman.googlecode.com/svn/trunk/ noidman-read-only  
```
<p>
Fix up permissions<br>
</p>
```
chown -R apache:apache /var/www/arks
```
<p>
Restart Apache<br>
</p>
```
/etc/init.d/apache restart
```
<h2>Migrating a new release into production</h2>
<p>
Check versions of Ruby and Rails<br>
</p>
```
ruby -v
rails -v
```
<p>
Update gems if appropriate to release<br>
</p>
```
sudo gem update
sudo gem cleanup
```
<p>
Change into Noidman directory, move working copy, checkout production-tagged release, let Apache account own the app<br>
</p>
```
cd /var/www/arks/
sudo mv noidman noidman-0.1.0
sudo svn checkout http://noidman.googlecode.com/svn/trunk/ noidman-read-only  
sudo chown -R apache:apache noidman-read-only
```
<p>
If Rails has not been frozen in the application's "vendor" directory, make sure RAILS_GEM_VERSION in environment.rb matches version of Rails installed<br>
</p>
<p>
Kill FCGI processes (just to be sure), and restart Apache<br>
</p>
```
for fcgi_pid in `ps -ef | grep noidman | grep -v grep | awk '{ print $2 }'`; do sudo kill -9 $fcgi_pid; done
sudo /etc/init.d/apache2 restart
```
<p>
If you can't load the app in a browser, check /var/log/apache2/error_log and noidman/log/<code>*</code>.log.<br>
</p>