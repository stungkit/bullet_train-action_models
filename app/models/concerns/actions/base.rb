module Actions::Base
  extend ActiveSupport::Concern

  included do
    after_commit :dispatch, on: [:create]
  end

  def dispatch
    perform
  end

  def before_start
    update(started_at: Time.zone.now)
  end

  def started?
    started_at.present?
  end

  def after_completion
    update(completed_at: Time.zone.now)
  end

  def completed?
    completed_at.present?
  end

  def before_each
  end

  def after_each
  end

  def perform
    raise "You need to define `perform`. Did you forget to include `Actions::TargetsMany` or `Actions::TargetsOne`?"
  end
end
