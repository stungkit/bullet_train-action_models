module Actions::TargetsOne
  extend ActiveSupport::Concern
  include Actions::Base

  included do
  end

  module ClassMethods
  end

  def set_target_count
    raise "You need to define `set_target_count`."
  end
end
