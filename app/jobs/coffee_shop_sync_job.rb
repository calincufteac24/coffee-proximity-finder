class CoffeeShopSyncJob < ApplicationJob
  queue_as :default

  def perform
    CoffeeShopSynchronizer.new.call
  end
end
