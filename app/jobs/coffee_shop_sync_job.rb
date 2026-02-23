class CoffeeShopSyncJob < ApplicationJob
  queue_as :default

  def perform
    # CoffeeShops::Synchronizer.new.call
  end
end
