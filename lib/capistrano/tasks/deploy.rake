##
 # Copyright © 2016 by David Alger. All rights reserved
 # 
 # Licensed under the Open Software License 3.0 (OSL-3.0)
 # See included LICENSE file for full text of OSL-3.0
 # 
 # http://davidalger.com/contact/
 ##

namespace :deploy do
  before 'deploy:check:linked_files', 'magento:deploy:check'

  task :updated do
    on release_roles :all do
      invoke 'magento:deploy:verify'
      invoke 'magento:composer:install' if fetch(:magento_deploy_composer)
      invoke 'magento:setup:permissions'
      if fetch(:magento_deploy_production)
        invoke 'magento:setup:static-content:deploy'
        invoke 'magento:setup:di:compile'
      end
      invoke 'magento:setup:permissions'
      if test '-d #{current_path}'
        within current_path do
          execute :magento, 'maintenance:enable'
        end
      end
      invoke 'magento:maintenance:enable' if fetch(:magento_deploy_maintenance)
      invoke 'magento:setup:upgrade'
    end
  end

  task :published do
    on release_roles :all do
      invoke 'magento:cache:flush'
      invoke 'magento:cache:varnish:ban'
      invoke 'magento:maintenance:disable' if fetch(:magento_deploy_maintenance)
    end
  end

  task :reverted do
    on release_roles :all do
      invoke 'magento:maintenance:disable' if fetch(:magento_deploy_maintenance)
      invoke 'magento:cache:flush'
      invoke 'magento:cache:varnish:ban'
    end
  end
end

namespace :load do
  task :defaults do
    set :magento_deploy_composer, fetch(:magento_deploy_composer, true)
    set :magento_deploy_production, fetch(:magento_deploy_production, true)
    set :magento_deploy_maintenance, fetch(:magento_deploy_maintenance, true)
  end
end
