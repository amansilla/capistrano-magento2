##
 # Copyright © 2016 by David Alger. All rights reserved
 # 
 # Licensed under the Open Software License 3.0 (OSL-3.0)
 # See included LICENSE file for full text of OSL-3.0
 # 
 # http://davidalger.com/contact/
 ##

require 'capistrano-pending'

namespace :deploy do
  before :starting, 'deploy:pending:check_changes'

  namespace :pending do
    # Check for pending changes and notify user of incoming changes or warn them that there are no changes
    task :check_changes => :setup do
      on roles fetch(:capistrano_pending_role, :app) do |host|
        # check for pending changes only if REVISION file exists to prevent error
        if test "[ -f #{current_path}/REVISION ]"
          from = fetch(:revision)
          to = fetch(:branch)

          output = _scm.log(from, to, true)
          if output.to_s.strip.empty?
            puts "\e[0;31m"
            puts "    No changes to deploy (from and to are the same: #{from}..#{to})"
            print "    Are you sure you want to continue deploying? [y/n] \e[0m"

            proceed = STDIN.gets[0..0] rescue nil
            exit unless proceed == 'y' || proceed == 'Y'
          else
            puts "Deploying changes between #{from}..#{to}"
            puts output
          end
        end
      end
    end
  end
end
