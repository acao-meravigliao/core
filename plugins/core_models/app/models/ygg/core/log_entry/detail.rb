module Ygg
module Core
class LogEntry < ActiveRecord::Base

class Detail < ActiveRecord::Base
  self.table_name = 'core.log_entry_details'

  belongs_to :log_entry,
             class_name: '::Ygg::Core::LogEntry'

  belongs_to :obj,
             polymorphic: true,
             optional: true

  serialize :obj_snapshot

  def previous
    self.class.order('id DESC').where('id < ?', id).where(obj_id: obj_id, obj_type: obj_type).first
  end
end

end
end
end
