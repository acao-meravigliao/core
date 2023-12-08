#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require 'hooks'

module Ygg
module Core

module Taskable
  extend ActiveSupport::Concern

  include Labeled

  included do
    include Hooks unless included_modules.include?(Hooks)
    define_hooks :task_completed, :task_failed, :task_canceled, :task_start_execution
  end

  def task_start_execution!(task)
    run_hook(:task_start_execution, task)
  end

  def task_completed!(task)
    run_hook(:task_completed, task)
  end

  def task_failed!(task)
    run_hook(:task_failed, task)
  end

  def task_canceled!(task)
    run_hook(:task_canceled, task)
  end
end

end
end
