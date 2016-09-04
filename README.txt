FiRe - File Replicator
======================
This program aids in keeping various data-libs up-to-date or just keeping
backups. But beware that this program copies files, so use it at your own risk.

INSTALL & TEST
In source root, execute:
1. gem install Bundler
2. bundle install
3. ruby  test/ts_fire.rb

HOW TO RUN
You need to call "ruby lib/fire.rb -config mycfg.yml" with your own config-file as 
input argument. Proceed as follows:
 
1. see the file bin/mediafire.sh for an example of how to execute.  
2. go to the config-folder and look in the fire.yml-file, and perhaps also the mediafire.yml.
   Edit a config-file (or copy a new one) so that you get your own configuration to execute 
   program with.
3. if you want more to do you can try to add your own copier, see the fire.yml for 
   explanation about how to do this.
4. As said, execute with your own config-file: 
		
		>ruby lib/fire.rb -config config/mycfg.yml
	
BACKGROUND
This program was written because I needed different copy-procedures for different sources. 
It also seemed like a good opportunity to practice some Ruby. It is a small program but
nonetheless aids with some heavy stuff. 
