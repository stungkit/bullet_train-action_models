module Actions::HasProgress
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
  end

  def completion_percent
    return 0 unless target_count
    (performed_count.to_f / target_count.to_f) * 100.0
  end

  def increment_performed_count
    # We do this over `increment!` because it triggers the callbacks that update the UI.
    update(performed_count: performed_count + 1)
  end

  def set_target_count
    unless defined?(super)
      raise "You need to define `set_target_count`. Did you forget to include `Actions::TargetsMany`?"
    end
  end

  def before_start
    update(started_at: Time.zone.now)
    set_target_count
    super
  end

  def after_each
    increment_performed_count
    super
  end

  def after_completion
    update(completed_at: Time.zone.now)
    super
  end
end