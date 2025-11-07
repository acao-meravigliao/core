module Ygg
module I18n
class Phrase < Ygg::PublicModel

class Translation < Ygg::YggModel
  self.table_name = 'i18n.translations'

  belongs_to :phrase,
             class_name: '::Ygg::I18n::Phrase'

  belongs_to :language,
             class_name: '::Ygg::I18n::Language'

  define_default_log_controller(self)
end

end
end
end
